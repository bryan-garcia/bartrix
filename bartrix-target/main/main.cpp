#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "stdio.h"
#include "iostream"

extern "C" void app_main(void)
{
    esp_rom_gpio_pad_select_gpio(GPIO_NUM_2);
    gpio_set_direction(GPIO_NUM_2, GPIO_MODE_OUTPUT);

    std::cout << "Now we can call C++ bitch" << std::endl;

    while (1)
    {
        gpio_set_level(GPIO_NUM_2, 1); // Turn LED on
        vTaskDelay(500 / portTICK_PERIOD_MS);
        gpio_set_level(GPIO_NUM_2, 0); // Turn LED off
        vTaskDelay(500 / portTICK_PERIOD_MS);
    }
}
