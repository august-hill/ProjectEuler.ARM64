// Problem 173: Using up to one million tiles how many hollow square laminae can be formed?
// Answer: 1572729
#include <math.h>
#include "../bench.h"

long long solve(void) {
    long long count = 0;
    long long limit = 1000000;

    for (long long n = 3; ; n++) {
        long long m_min = (n % 2 == 0) ? 2 : 1;
        long long m_max = n - 2;
        if (n * n - m_max * m_max > limit) break;

        long long m_sq_min = n * n - limit;
        long long actual_m_min = m_min;
        if (m_sq_min > 0) {
            actual_m_min = (long long)sqrt((double)m_sq_min);
            if (actual_m_min * actual_m_min < m_sq_min) actual_m_min++;
        }
        if (actual_m_min < m_min) actual_m_min = m_min;
        if ((actual_m_min % 2) != (n % 2)) actual_m_min++;
        if (actual_m_min > m_max) continue;

        count += (m_max - actual_m_min) / 2 + 1;
    }

    return count;
}

int main(void) { euler_bench(173, solve); return 0; }
