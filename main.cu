#include <cuda.h>
#include <iostream>
#include <cmath>
#include <chrono>
#define NUM_THREADS 128


int *number_sum_h;
int *number_sum_d;
int *numbers_d;
// int *numbers_h;
int blks;

__global__ void generate_numbers(int* numbers_d, int size){
     int tid = threadIdx.x + blockIdx.x * blockDim.x;
     if (tid >= size){
        return;
     }
    numbers_d[tid] = tid % 10;
    // printf("%d \n",tid);
}
__global__ void stencil(int* numbers_d, int size, int *number_sum_d){
     int tid = threadIdx.x + blockIdx.x * blockDim.x;
     if (tid >= size){
        return;
     }
     int num0=0;
     int num1=0;
     int num2=0;
     int num3=0;
     int num4=0;
     int num5=0;
     if(tid > 1){
        num0 = numbers_d[tid-2];
     }
     if(tid > 0){
        num1 = numbers_d[tid-1];
     }
     if(tid < size -2){
        num5 = numbers_d[tid+2];
     }
    if(tid < size -1){
        num4 = numbers_d[tid+1];
     }
    num3 = numbers_d[tid];
    number_sum_d[tid] = num0 + num1 + num2 + num3 + num4 + num5;
}

int find_arg_idx(int argc, char** argv, const char* option) {
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], option) == 0) {
            return i;
        }
    }
    return -1;
}

int find_int_arg(int argc, char** argv, const char* option, int default_value) {
    int iplace = find_arg_idx(argc, argv, option);

    if (iplace >= 0 && iplace < argc - 1) {
        return std::stoi(argv[iplace + 1]);
    }

    return default_value;
}


int main(int argc, char** argv){
    int N = find_int_arg(argc, argv, "-n", 1000);
    printf("%d \n", N);
    float quotient;
    quotient = float(N/NUM_THREADS);
    blks = ceil(int(quotient)) + 1;
    cudaMalloc(&numbers_d, N * sizeof(int));
    cudaMalloc(&number_sum_d, N * sizeof(int));
    generate_numbers <<<blks ,NUM_THREADS>>>(numbers_d, N);
    cudaDeviceSynchronize();
    auto start_time = std::chrono::steady_clock::now();
    stencil<<<blks,NUM_THREADS>>>(numbers_d,N, number_sum_d);
    cudaDeviceSynchronize();
    auto end_time = std::chrono::steady_clock::now();
    std::chrono::duration<double> diff = end_time - start_time;
    double seconds = diff.count();
    std::cout << "Simulation Time = " << seconds << " seconds \n";
    // cudaError_t cudaerr = cudaDeviceSynchronize();
    // if (cudaerr != cudaSuccess)
    //     printf("kernel launch failed with error \"%s\".\n",
    //     cudaGetErrorString(cudaerr));
    number_sum_h = new int[N];
    cudaMemcpy(number_sum_h, number_sum_d, N * sizeof(int), cudaMemcpyDeviceToHost);

    delete[] number_sum_h;
    cudaFree(numbers_d);
    return 0;
}