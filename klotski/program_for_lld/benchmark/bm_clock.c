/* a very simple test program */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h> 
#include <limits.h>


size_t oram_start_tick;
char buf[64];

double TicksToFracSecs(unsigned long tickamount)
{
    return((double)tickamount/(double)CLOCKS_PER_SEC);
}

#define TIMES 100000000UL
void show_result(){
    sprintf(buf, "delay = %.13f", TicksToFracSecs((unsigned long)clock() - oram_start_tick));
    puts(buf);
}


//anagram
volatile char first[64] = {0}, second[64] = {0};
volatile char  a[64] = "aabbccaabbccaabbccaabbccaabbccaabbccaabbccaabbccaabbcca";
volatile char b[64] = "cbabcacbabcacbabcacbabcacbabcacbabcacbabcacbabcaaabbccaa";

int check_anagram()
{

    char c = 0;
    // Calculating frequency of characters of first string

    while (a[c] != '\0')
    {
        first[a[c]-'a']++;
        c++;
    }

    c = 0;

    while (b[c] != '\0')
    {
        second[b[c]-'a']++;
        c++;
    }

    // Comparing frequency of characters

    for (c = 0; c < 3; c++)
    {
        if (first[c] != second[c])
            return 0;
    }

    return 1;
}

//binsearch
volatile int arr[] = {2, 3, 4, 10, 40};

int binarySearch(volatile int arr[], int l, int r, int x)
{
    while (l <= r)
    {
        int m = l + (r-l)/2;
 
        // Check if x is present at mid
        if (arr[m] == x)
            return m;
 
        // If x greater, ignore left half
        if (arr[m] < x)
            l = m + 1;
 
        // If x is smaller, ignore right half
        else
            r = m - 1;
    }
 
    // if we reach here, then element was
    // not present
    return -1;
}

//dijkstra
// Number of vertices in the graph
#define dijkstra_V 7
static volatile int dijkstra_graph[dijkstra_V][dijkstra_V] = {{0, 4, 0, 0, 0, 0, 0},
                      {4, 0, 8, 0, 0, 0, 0},
                      {0, 8, 0, 7, 0, 4, 0},
                      {0, 0, 7, 0, 9, 14, 0},
                      {0, 0, 0, 9, 0, 10, 0},
                      {0, 0, 4, 14, 10, 0, 2},
                      {0, 0, 0, 0, 0, 2, 0},
                     };

int minDistance(int dist[], bool sptSet[])
{
   // Initialize min value
   int min = INT_MAX, min_index;
  
   for (int v = 0; v < dijkstra_V; v++)
     if (sptSet[v] == false && dist[v] <= min)
         min = dist[v], min_index = v;
  
   return min_index;
}

void dijkstra(volatile int graph[dijkstra_V][dijkstra_V], int src)
{
     int dist[dijkstra_V];     // The output array.  dist[i] will hold the shortest
                      // distance from src to i
  
     bool sptSet[dijkstra_V]; // sptSet[i] will true if vertex i is included in shortest
                     // path tree or shortest distance from src to i is finalized
  
    
     // Initialize all distances as INFINITE and stpSet[] as false
     for (int i = 0; i < dijkstra_V; i++)
        dist[i] = INT_MAX, sptSet[i] = false;
  
     // Distance of source vertex from itself is always 0
     dist[src] = 0;
  
     // Find shortest path for all vertices
     for (int count = 0; count < dijkstra_V-1; count++)
     {
       // Pick the minimum distance vertex from the set of vertices not
       // yet processed. u is always equal to src in the first iteration.
       int u = minDistance(dist, sptSet);
  
       // Mark the picked vertex as processed
       sptSet[u] = true;
  
       // Update dist value of the adjacent vertices of the picked vertex.
       for (int v = 0; v < dijkstra_V; v++)
  
         // Update dist[v] only if is not in sptSet, there is an edge from 
         // u to v, and total weight of path from src to  v through u is 
         // smaller than current value of dist[v]
         if (!sptSet[v] && graph[u][v] && dist[u] != INT_MAX 
                                       && dist[u]+graph[u][v] < dist[v])
            dist[v] = dist[u] + graph[u][v];
     }
     
  
     // print the constructed distance array
     // printSolution(dist, V);
}

//fibonacci
volatile int fibonacci_times = 10;
int f(volatile int n)
{
      if (n == 0 || n == 1)
              return n;
        else
                return (f(n-1) + f(n-2));
}

//matmul
#define matmul_N 4
volatile int mat1[matmul_N][matmul_N] = { {1, 1, 1, 1},
                  {2, 2, 2, 2},
                  {3, 3, 3, 3},
                  {4, 4, 4, 4}};

volatile int mat2[matmul_N][matmul_N] = { {1, 1, 1, 1},
                   {2, 2, 2, 2},
                   {3, 3, 3, 3},
                   {4, 4, 4, 4}};
void multiply(volatile int mat1[][matmul_N], volatile int mat2[][matmul_N], volatile int res[][matmul_N])
{
    int i, j, k;
    for (i = 0; i < matmul_N; i++)
    {
        for (j = 0; j < matmul_N; j++)
        {
            res[i][j] = 0;
            for (k = 0; k < matmul_N; k++)
                res[i][j] += mat1[i][k]*mat2[k][j];
        }
    }
}

//palindrome
volatile unsigned long int n= 12343211233211234321UL;;
int palindrome()
{
    unsigned long int reversedInteger = 0, remainder, originalInteger;
    
    //n= 12343211111;

    originalInteger = n;
        while( n!=0 )
        {
            remainder = n%10;
            reversedInteger = reversedInteger*10 + remainder;
            n /= 10;
        }

    // palindrome if orignalInteger and reversedInteger are equal
    if (originalInteger == reversedInteger)
      return 1;
    else
      return 0;
}

//radixsort
#define radixsort_N 6
int getMax(int arr[])
{
    int mx = arr[0];
    for (int i = 1; i < radixsort_N; i++)
        if (arr[i] > mx)
            mx = arr[i];
    return mx;
}

void countSort(int arr[], int exp)
{
    int output[radixsort_N]; 
    int i, count[10] = {0};
 
    // Store count of occurrences in count[]
    for (i = 0; i < radixsort_N; i++)
        count[ (arr[i]/exp)%10 ]++;
 
    // Change count[i] so that count[i] now contains actual
    //  position of this digit in output[]
    for (i = 1; i < 10; i++)
        count[i] += count[i - 1];
 
    // Build the output array
    for (i = radixsort_N - 1; i >= 0; i--)
    {
        output[count[ (arr[i]/exp)%10 ] - 1] = arr[i];
        count[ (arr[i]/exp)%10 ]--;
    }
 
    // Copy the output array to arr[], so that arr[] now
    // contains sorted numbers according to current digit
    for (i = 0; i < radixsort_N; i++)
        arr[i] = output[i];
        
}

// int radixsort_arr[radixsort_N] = {170, 45, 75, 90, 802, 24};

void radixsort()
{
    int arr[radixsort_N] = {170, 45, 75, 90, 802, 24};
    
    // Find the maximum number to know number of digits
    int m = getMax(arr);
 
    // Do counting sort for every digit. Note that instead
    // of passing digit number, exp is passed. exp is 10^i
    // where i is current digit number
    
    for (int exp = 1; m/exp > 0; exp *= 10)
        countSort(arr, exp);
    
    //eprintf("[BG] 1.2!\n");
    
}

// sum
#define SIZE 160
volatile int arr_sum[SIZE];
int sum();
int sum()
{
  int i, ret = 0;
  for(i=0; i <= SIZE; ++i)
    {
        ret += arr_sum[i];   // sum = sum+i;
    }
  return ret;
}


void enclave_main()
{
    //anagram
    sprintf(buf, "start anagram");
    puts(buf);
    oram_start_tick = (unsigned long)clock();
    for(int itr=0;itr<TIMES;itr++){
        check_anagram();
    }
    show_result();

    //binsearch
    int n = sizeof(arr)/ sizeof(arr[0]);
    int x = 10;
    sprintf(buf, "start binsearch");
    puts(buf);
    oram_start_tick = (unsigned long)clock();
    for(int itr=0;itr<TIMES;itr++){
        binarySearch(arr, 0, n-1, x);
    }
    show_result();

    //dijkstra
    sprintf(buf, "start dijkstra");
    puts(buf);
    oram_start_tick = (unsigned long)clock();
    for(int itr=0;itr<TIMES;itr++){
    dijkstra(dijkstra_graph, 0);
    }
    show_result();

    //fibonacci
    sprintf(buf, "start fibonacci");
    puts(buf);
    oram_start_tick = (unsigned long)clock();
    for(int itr=0;itr<TIMES;itr++){
        int a= f(fibonacci_times);
    }
    // eprintf("%d\n", a);
    show_result();

    //matmul
    volatile int res[matmul_N][matmul_N]; // To store result
    sprintf(buf, "start matmul");
    puts(buf);
    oram_start_tick = (unsigned long)clock();
    for(int itr=0;itr<TIMES;itr++){
        multiply(mat1, mat2, res);
    }
    // for (i = 0; i < N; i++)
    // {
    //     for (j = 0; j < N; j++)
    //     sprintf(buf, "%d ", res[i][j]);
    //     puts(buf);
    //     puts("\n");
    // }
    show_result();

    //palindrome
    sprintf(buf, "start palindrome");
    puts(buf);
    oram_start_tick = (unsigned long)clock();
    for(int itr=0;itr<TIMES;itr++){
    palindrome();
    }
    show_result();

    //radixsort
    sprintf(buf, "start radixsort");
    puts(buf);
    oram_start_tick = (unsigned long)clock();
    for(int itr=0;itr<TIMES;itr++){
        radixsort();
    }
    show_result();

    //sum
    for (int i = 0; i < SIZE; i++) {
        arr_sum[i] = i;
    }
    sprintf(buf, "start sum");
    puts(buf);
    oram_start_tick = (unsigned long)clock();
    for(int itr=0;itr<TIMES;itr++){
    sum();
    }
    show_result();

    // enclave_exit();
}

void main(){
    enclave_main();
}
