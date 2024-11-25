#include <jetson-utils/videoSource.h>
#include <jetson-utils/videoOutput.h>
#include <iostream>

#define HISTOGRAM_MAX 256
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

__global__ void calcHistogramKernel(uchar4* image, int* histo , int width , int height  ) {
    int index = blockIdx.x * blockDim.x + threadIdx.x ; 
    int stride = blockDim.x * gridDim.x;
    int gray ;
    //process here 
    for( int i = index ; i < 1280 * 720 ; i += stride) {
        gray = image[i].x * 0.299f + image[i].y * 0.587f + image[i].z * 0.114f;
        // gray = image[i].x
        histo[gray] += 1; 
    }

}

int main( int argc, char** argv )
{
    //prerequisits for kernel programming 
    int blocksize = 256;
    int width = 1280;
    int height = 720;
    int N = width * height;
    int numBlocks = (N + blocksize - 1 ) / blocksize ;
 ///921600
    ///(((Histogram)))
    int *histo ;
    int temp_calc;

    cudaMalloc(&histo , HISTOGRAM_MAX * sizeof(int));
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
            rgb2grayKernel<<<numBlocks, blocksize>>>(image, width, height, image_gray);
            calcHistogramKernel<<<numBlocks, blocksize>>>(image, histo , width , height);

            for(int i = 0 ; i < 256 ; i++) {
                temp_calc += histo[i];
            }
            printf("%d" , temp_calc);

            
            cudaMemset(histo , 0 , 256*sizeof(int));

            //
            output->Render(image, input->GetWidth(), input->GetHeight());
            output_2->Render(image_gray, input->GetWidth(), input->GetHeight());
            
            // Update status bar
            char str[256];
            sprintf(str, "Camera Viewer (%ux%u) | %0.1f FPS", input->GetWidth(),
            input->GetHeight(), output->GetFrameRate());
            output->SetStatus(str);

            if (!output->IsStreaming()) // check if the user quit
            break;
        }
    }
}



// nvcc ex1v1.cu -o ex1v1 -ljetson-utils
// ./ex1v1
//  sudo /usr/local/cuda/bin/nvprof --print-gpu-summary ./ex1v1
