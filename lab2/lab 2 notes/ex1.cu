#include <iostream> 
#include <math.h> 
  
__global__ void multKernel(int n, float* a, float* b, float* c) 
{ 
    for (int i = 0; i < n; i++) { 
        c[i] = a[i] * b[i]; 
    } 
} 
  
int main() { 
    int N = 1<<24; 
    float *h_a, *h_b, *h_c; 
    float *d_a, *d_b, *d_c; 
  
    // Allocate host memory 
    h_a = new float[N]; 
    h_b = new float[N]; 
    h_c = new float[N]; 
  
    // Allocate device memory 
    cudaMalloc(&d_a, N * sizeof(float)); 
    cudaMalloc(&d_b, N * sizeof(float)); 
    cudaMalloc(&d_c, N * sizeof(float)); 
  
    // Initialize host data 
    for (int i = 0; i < N; i++) 
    { 
        h_a[i] = 2.0f; 
        h_b[i] = 3.0f; 
    } 
  
    // Copy data from host to device 
    cudaMemcpy(d_a, h_a, N * sizeof(float), cudaMemcpyHostToDevice); 
    cudaMemcpy(d_b, h_b, N * sizeof(float), cudaMemcpyHostToDevice); 
  
    // Launch the kernel 
    multKernel<<<1, 1>>>(N, d_a, d_b, d_c); 
  
    // Copy result back to host 
    cudaMemcpy(h_c, d_c, N * sizeof(float), cudaMemcpyDeviceToHost); 
  
    // Check result for errors (all values should be 6.0f) 
    float maxError = 0.0f; 
    for (int i = 0; i < N; i++) 
        maxError = fmax(maxError, fabs(h_c[i] - 6.0f)); 
    std::cout << "Max error: " << maxError << std::endl; 
  
    // Clean up 
    cudaFree(d_a); 
    cudaFree(d_b); 
    cudaFree(d_c); 
    delete[] h_a; 
    delete[] h_b; 
    delete[] h_c; 
  
    return 0; 
}

/*
/// ASH CODE . Example on how to capture question 1 . 
#include <iostream>
#include <math.h>
#include <cuda_runtime.h>

__global__ void multKernel(int n, float* a, float* b, float* c) {
    for (int i = 0; i < n; i++) {
        c[i] = a[i] * b[i];
    }
}

int main() {
    int N = 1<<24; 
    float *h_a, *h_b, *h_c;
    float *d_a, *d_b, *d_c;

    // Allocate host memory
    h_a = new float[N];
    h_b = new float[N];
    h_c = new float[N];

    // Allocate device memory
    cudaMalloc(&d_a, N * sizeof(float));
    cudaMalloc(&d_b, N * sizeof(float));
    cudaMalloc(&d_c, N * sizeof(float));

    // Initialize host data
    for (int i = 0; i < N; i++) {
        h_a[i] = 2.0f;
        h_b[i] = 3.0f;
    }

    // Timing events
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Copy data from host to device
    cudaEventRecord(start);
    cudaMemcpy(d_a, h_a, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float hostToDeviceTime;
    cudaEventElapsedTime(&hostToDeviceTime, start, stop);

    // Launch the kernel
    cudaEventRecord(start);
    multKernel<<<1, 1>>>(N, d_a, d_b, d_c);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float kernelTime;
    cudaEventElapsedTime(&kernelTime, start, stop);

    // Copy result back to host
    cudaEventRecord(start);
    cudaMemcpy(h_c, d_c, N * sizeof(float), cudaMemcpyDeviceToHost);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float deviceToHostTime;
    cudaEventElapsedTime(&deviceToHostTime, start, stop);

    // Output timing results
    std::cout << "Time spent copying data from host to device: " << hostToDeviceTime << " ms" << std::endl;
    std::cout << "Time spent executing the kernel: " << kernelTime << " ms" << std::endl;
    std::cout << "Time spent copying data from device to host: " << deviceToHostTime << " ms" << std::endl;

    // Check result for errors (all values should be 6.0f)
    float maxError = 0.0f;
    for (int i = 0; i < N; i++)
        maxError = fmax(maxError, fabs(h_c[i] - 6.0f));
    std::cout << "Max error: " << maxError << std::endl;

    // Clean up
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    delete[] h_a;
    delete[] h_b;
    delete[] h_c;
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}



*/