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
        bubbleSort(numbers);
        convertToBinary(numbers);
        System.out.println("Медіана: " + median(numbers));
        System.out.println("Середнє значення: " + average(numbers));
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

    public static void bubbleSort(short[] numbers){
        for(int i = 0; i < numbers.length; i++){
            for(int j = 0; j < numbers.length - i - 1; j++){
                if(numbers[j] > numbers[j + 1]){
                    short temp = numbers[j];
                    numbers[j] = numbers[j + 1];
                    numbers[j + 1] = temp;
                }
            }
        }
    }

    public static double median(short[] numbers){
        if(numbers.length % 2 == 0){
            return (numbers[numbers.length / 2] + numbers[numbers.length / 2 - 1]) / 2.0;
        } else {
            return numbers[numbers.length / 2];
        }
    }

    public static double average(short[] numbers){
        double sum = 0;
        for(int i = 0; i < numbers.length; i++){
            sum += numbers[i];
        }
        return sum / numbers.length;
    }
}
