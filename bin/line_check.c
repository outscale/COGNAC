#include <unistd.h>
#include <stdint.h>
#include <stdio.h>

#define BUF_SIZE 2048

int main(int ac, char **av) {

	char buf[BUF_SIZE];
	size_t s;
	static int bufs_cnt[256];
	int i, j;

	if (ac > 254) {
		return -1;
	}

	while ((s = read(0, buf, BUF_SIZE)) > 0) {
		for (i = 0; i < s; ++i) {
			for (j = 1; j < ac; ++j) {
				if (!av[j][bufs_cnt[j]]) {
					printf("%s\n", av[j]);
					return 0;
				}
				if (av[j][bufs_cnt[j]] == buf[i])
					++bufs_cnt[j];
				else
					bufs_cnt[j] = 0;
			}
		}
	}

	return -1;
}
