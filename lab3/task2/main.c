#include<stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
void login();
void query();
void order();
void status();
void calc_rec_all();
#ifdef __cplusplus
}
#endif

int printv(int v)
{
	printf("avg = %d\n", v);
	return v;
}

void breakline() {
	putchar('\n');
}

void log(char* s) {
	printf("%s\n",s);
}

void log_int(int v)
{
	printf("%d", v);
}

void log_short(short v)
{
	printf("%d", v);
}

void log_char(char v)
{
	printf("%d", v);
}

void cls() {
	system("cls");
}

void menu() {
	printf("Options[1-9]:\n");
	printf("  1. login/re-login\n");
	printf("  2. query good\n");
	printf("  3. order\n");
	printf("  4. calculate recommend index\n");
	printf("  5. rank\n");
	printf("  6. modify good\n");
	printf("  7. transfer\n");
	printf("  8. current cs\n");
	printf("  9. exit\n");
}

int main(void)
{
	while (1) {
		status();
		menu();
		int option = 0;
		scanf_s("%d", &option);
		getchar();
		cls();
		switch (option) {
		case 1: {
			login();
			break;
		}
		case 2: {
			query();
			break;
		}
		case 3: {
			order();
			break;
		}
		case 4: {
			calc_rec_all();
			break;
		}
		case 9: {
			return 0; 
		}
		default: break;
		}
	}
	return 0;
}