#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "stdio.h"
#include "iostream"

extern "C" void app_main(void)
{
    esp_rom_gpio_pad_select_gpio(GPIO_NUM_2);
    gpio_set_direction(GPIO_NUM_2, GPIO_MODE_OUTPUT);

    int allocated = 0;
    int AMOUNT = 1000;
    printf("Hello world\n");

    std::cout << "Now we can call C++ bitch" << std::endl;

    while (1)
    {
        // gpio_set_level(BLINK_GPIO, 1);
        // vTaskDelay(100 / portTICK_PERIOD_MS);
        // gpio_set_level(BLINK_GPIO, 0);
        // vTaskDelay(100 / portTICK_PERIOD_MS);

        int addr = (int) malloc(AMOUNT);

        allocated += AMOUNT;
        printf("allocated %i\n", allocated);


        if (addr == 0) {
            return;
        }
    }
}
