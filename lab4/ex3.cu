#include <jetson-utils/videoSource.h>
#include <jetson-utils/videoOutput.h>
#include <iostream>


//numero uno deus batista


//1280 * 720

__global__ void rgb2grayKernel(uchar4* image , int width, int height , uchar4* image_gray){
    //Gray = 0.299*R + 0.587*G + 0.114*B
    int index = blockIdx.x * blockDim.x + threadIdx.x ; 
    int stride = blockDim.x * gridDim.x;
    float gray ;
    //process here 
    for ( int i = index ; i < 1280 * 720; i += stride) {
        gray = image[i].x * 0.299f + image[i].y * 0.587f + image[i].z * 0.114f;
        image_gray[i] = make_uchar4(gray, gray, gray, image[i].w); // Keep the alpha channel unchanged
    }
}
__global__ void plotHistogramKernel(uchar4* image, int* histogram, int width, int height, int max_freq)
{
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    uchar4 white_pixel = make_uchar4(255, 255, 255, 255);
    uchar4 black_pixel = make_uchar4(0, 0, 0, 255);
    if(index < 256){
        int freq = histogram[index] * 256 / max_freq;
        for(int i = 0 ; i < 256 ; i++){
            int row = height - i - 1;
            if (i <= freq) {
                image[row * width + 2*index] = white_pixel;
                image[row * width + 2*index+1] = white_pixel;
            }
            else {
                image[row * width + 2*index] = black_pixel;
                image[row * width + 2*index+1] = black_pixel;
            }
        }
    }
}

__global__ void makegrayimage (uchar4* image , int width, int height , uchar4* image_gray){
    //Gray = 0.299*R + 0.587*G + 0.114*B
    int index = blockIdx.x * blockDim.x + threadIdx.x ; 
    int stride = blockDim.x * gridDim.x;
    float gray ;
    //process here 
    for ( int i = index ; i < 1280 * 720; i += stride) {
        gray = (256*(i/width))/height;

        image_gray[i] = make_uchar4(gray, gray, gray, image[i].w); // Keep the alpha channel unchanged
    }
}


__global__ void calcHistogramKernel(uchar4* image, int* histo, int width, int height) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

 //intililizationsion of the shared mem 
    __shared__ int histo_local[256];

    if (threadIdx.x < 256) { //needed apparently
        histo_local[threadIdx.x] = 0;
    }
    __syncthreads();

 
    for (int i = index; i < width * height; i += stride) {
        int gray = image[i].x;  // since the image is already grayscale
        atomicAdd(&histo_local[gray], 1);  // atomic add within shared memory
    }

    __syncthreads();

    //updates my histo thats global
    if (threadIdx.x < 256) {
        atomicAdd(&histo[threadIdx.x], histo_local[threadIdx.x]);
    }
}





int main( int argc, char** argv )
{
    //prerequisits for kernel programming 
     int max_feq = 20000; 
    int blocksize = 256;
    int width = 1280;
    int height = 720;
    int N = width * height;
    int numBlocks = (N + blocksize - 1 ) / blocksize ;
 ///921600
    ///(((Histogram)))
    int *histo ;
    int copy_histo[256];
    int temp_val = 0;

    cudaMalloc(&histo , 256 * sizeof(int));
    cudaMemset(histo , 0 , 256*sizeof(int)); // to reset all to zero. do after each kernel






    //Allocate memory for pointers 
    //uchar4* h_i_buffer, h_o_buffer 
    uchar4 *image;
    uchar4 *image_gray; 

  
    //allocate device mem
    cudaMalloc(&image_gray , N * sizeof(uchar4));
   


    videoSource* input = videoSource::Create(argc, argv, ARG_POSITION(0));
    videoOutput* output = videoOutput::Create(argc, argv, ARG_POSITION(1));
    videoOutput* output_2 = videoOutput::Create(argc, argv, ARG_POSITION(1));
    if ( !input )
        return 0;

    // capture/display loop
    while (true)
    {
        
        int status = 0;

        // can be uchar3, uchar4, float3, float4
        // see videoSource::Status (OK, TIMEOUT, EOS,
        if ( !input->Capture(&image, 1000, &status) ) // 1000ms timeout (default)
        {
            if (status == videoSource::TIMEOUT) 
                continue;
                
            break; // EOS
        }
        
        if ( output != NULL )
        {
            //start kernel here before Render
            makegrayimage<<<numBlocks, blocksize>>>(image, width, height, image_gray);
            calcHistogramKernel<<<numBlocks, blocksize>>>(image_gray, histo , width , height);
            plotHistogramKernel<<<numBlocks , blocksize>>>(image_gray, histo, width, height, max_feq);
            //printing and calculation
            cudaMemcpy(copy_histo, histo, 256 *sizeof(int), cudaMemcpyDeviceToHost);
            cudaDeviceSynchronize();
            for(int i = 0 ; i < 256 ; i++) {
                temp_val += copy_histo[i];
            }
            
            
            //reset
            cudaMemset(histo , 0 , 256*sizeof(int));
            
            //
            output->Render(image, input->GetWidth(), input->GetHeight());
            output_2->Render(image_gray, input->GetWidth(), input->GetHeight());
            
            // Update status bar
            char str[256];
            sprintf(str, "%d   Camera Viewer (%ux%u) | %0.1f FPS", temp_val,  input->GetWidth(),
            input->GetHeight(), output->GetFrameRate());
            output->SetStatus(str);
            temp_val = 0;

            if (!output->IsStreaming()) // check if the user quit
            break;
        }
    }
}




// nvcc ex3.cu -o ex3 -ljetson-utils
// ./ex3
//  sudo /usr/local/cuda/bin/nvprof --print-gpu-summary ./ex3
