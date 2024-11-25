#if 0
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <arm_neon.h>
void mult_std(float* a, float* b, float* r, int num)
{
for (int i = 0; i < num; i++)
{
r[i] = a[i] * b[i];
}
}
void mult_vect(float* a, float* b, float* r, int num)
{
float32x4_t va, vb, vr;
for (int i = 0; i < num; i +=4)
{
va = vld1q_f32(&a[i]);
vb = vld1q_f32(&b[i]);
vr = vmulq_f32(va, vb);
vst1q_f32(&r[i], vr);
}
}
int main(int argc, char *argv[]) {
int num = 100000000;
float *a = (float*)aligned_alloc(16, num*sizeof(float));
float *b = (float*)aligned_alloc(16, num*sizeof(float));
float *r = (float*)aligned_alloc(16, num*sizeof(float));
for (int i = 0; i < num; i++)
{
a[i] = (i % 127)*0.1457f;
b[i] = (i % 331)*0.1231f;
}
struct timespec ts_start;
struct timespec ts_end_1;
struct timespec ts_end_2;
clock_gettime(CLOCK_MONOTONIC, &ts_start);
mult_std(a, b, r, num);
clock_gettime(CLOCK_MONOTONIC, &ts_end_1);
mult_vect(a, b, r, num);
clock_gettime(CLOCK_MONOTONIC, &ts_end_2);
double duration_std = (ts_end_1.tv_sec - ts_start.tv_sec) +
(ts_end_1.tv_nsec - ts_start.tv_nsec) * 1e-9;
double duration_vec = (ts_end_2.tv_sec - ts_end_1.tv_sec) +
(ts_end_2.tv_nsec - ts_end_1.tv_nsec) * 1e-9;
printf("Elapsed time std: %f\n", duration_std);
printf("Elapsed time vec: %f\n", duration_vec);
free(a);
free(b);
free(r);
return 0;
}
#else
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <arm_neon.h>
#include <pthread.h>

#define NUM_THREADS 4

int num = 100000000;
float *b;
float *r;
float *a;

void* mult_std(void* start) {
    int *s = (int*)start;
    for (int i = *s; i < *s + num / NUM_THREADS; i++) {
        r[i] = a[i] * b[i];
    }
    return NULL;
}

void* mult_vect(void* start) {
    int *s = (int*)start;
    float32x4_t va, vb, vr;
    for (int i = *s; i < *s + num / NUM_THREADS; i += 4) {
        va = vld1q_f32(&a[i]);
        vb = vld1q_f32(&b[i]);
        vr = vmulq_f32(va, vb);
        vst1q_f32(&r[i], vr);
    }
    return NULL;
}

void mult_thread_std() {
    pthread_t threads[NUM_THREADS];
    int rc;

    for (long t = 0; t < NUM_THREADS; t++) {
        int* start = malloc(sizeof(int)); // Allocate memory for start
        *start = t * num / NUM_THREADS; // Set the start index
        
        rc = pthread_create(&threads[t], NULL, mult_std, (void*)start);
        if (rc) {
            printf("Error: Unable to create thread, %d\n", rc);
            exit(-1);
        }
    }

    for (long t = 0; t < NUM_THREADS; t++) {
        pthread_join(threads[t], NULL);
    }
}

void mult_thread_vect() {
    pthread_t threads[NUM_THREADS];
    int rc;

    for (long t = 0; t < NUM_THREADS; t++) {
        int* start = malloc(sizeof(int)); // Allocate memory for start
        *start = t * num / NUM_THREADS; // Set the start index

        rc = pthread_create(&threads[t], NULL, mult_vect, (void*)start);
        if (rc) {
            printf("Error: Unable to create thread, %d\n", rc);
            exit(-1);
        }
    }

    for (long t = 0; t < NUM_THREADS; t++) {
        pthread_join(threads[t], NULL);
    }
}

int main(int argc, char *argv[]) {
    a = (float*)aligned_alloc(16, num * sizeof(float));
    b = (float*)aligned_alloc(16, num * sizeof(float));
    r = (float*)aligned_alloc(16, num * sizeof(float));

    for (int i = 0; i < num; i++) {
        a[i] = (i % 127) * 0.1457f;
        b[i] = (i % 331) * 0.1231f;
    }

    struct timespec ts_start;
    struct timespec ts_end_1;
    struct timespec ts_end_2;
    
    clock_gettime(CLOCK_MONOTONIC, &ts_start);
    mult_thread_std();
    clock_gettime(CLOCK_MONOTONIC, &ts_end_1);
    
    mult_thread_vect();
    clock_gettime(CLOCK_MONOTONIC, &ts_end_2);
    
    double duration_std = (ts_end_1.tv_sec - ts_start.tv_sec) + (ts_end_1.tv_nsec - ts_start.tv_nsec) * 1e-9;
    double duration_vec = (ts_end_2.tv_sec - ts_end_1.tv_sec) + (ts_end_2.tv_nsec - ts_end_1.tv_nsec) * 1e-9;

    printf("Elapsed time std: %f\n", duration_std);
    printf("Elapsed time vec: %f\n", duration_vec);
    
    free(a);
    free(b);
    free(r);
    return 0;
}
#endif