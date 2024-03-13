/*
    Прочитати з stdin N десяткових чисел, розділених пробілом чи новим рядком до появи EOF (макс довжина рядка 255 символів),
    кількість чисел може до 10000.
     Рядки розділяються АБО послідовністю байтів 0x0D та 0x0A (CR LF), або одним символом - 0x0D чи 0x0A.
    Кожне число це ціле десяткове знакове число, яке треба конвертувати в бінарне представлення (word в доповнювальному коді).
    Від'ємні числа починаються з '-'.
    Увага: якщо число занадто велике за модулем для 16-бітного представлення зі знаком, таке значення має бути представлене як
    максимально можливе (за модулем).
    Відсортувати бінарні значення алгоритмом bubble sort (asc). Якщо merge sort - буде додатковий бал.

    Обчислити значення медіани та вивести десяткове в консоль як рядок (stdout)

    Обчислити середнє значення та вивести десяткове в консоль як рядок (stdout)
 */

import java.util.Scanner;
public class Calculations {
    public static void main(String[] args){
        Scanner scanner = new Scanner(System.in);

        int n = 3; //amount of numbers to read
        short[] numbers = new short[n];

        for (int i = 0; i < n; i++){
            short number = scanner.nextShort();

            if(number > 32767){
                number = 32767;
            } else if(number < -32768){
                number = -32768;
            }
            numbers[i] = number;
        }
        convertToBinary(numbers);
    }

    public static void convertToBinary(short[] numbers){
        for(int i = 0; i < numbers.length; i++){
            System.out.println(toBinarySigned(numbers[i]));
        }
    }

    public static String toBinarySigned(short value) {
        StringBuilder binary = new StringBuilder();
        for (int i = 15; i >= 0; i--) {
            binary.append((value >> i) & 1);
        }
        return binary.toString();
    }
}
