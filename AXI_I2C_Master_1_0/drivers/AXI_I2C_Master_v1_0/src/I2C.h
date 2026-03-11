/**
 * @file I2C.h
 * @brief 
 * @version 0.1
 * @date 2026-02-15
 * 
 * @copyright Copyright (c) 2026
 * 
 */
#include "Xil_io.h"

#define BASE_ADRESS     0x00
#define CNTRL_REG       BASE_ADRESS+0x0
#define WRITE_REG       BASE_ADRESS+0x4
#define READ_REG        BASE_ADRESS+0x8

#define EN_POS  0
#define ST_POS  1
#define SP_POS  2
#define RD_POS  3
#define FF_POS 4


#define DATA_POS    8
#define ADDRESS_POS 0

#define SIZE_POS 0
#define READ_POS 8


typedef struct {
    uint32_t _address;
}I2C;


void setAddress(I2C *i2c_obj, uint32_t address);


/**
 * @brief Este método finaliza la operación del bloque IP del I2C.
 * 
 * @code 
 * 
 * #include "I2C.hpp"
 * 
 * #define ADDRESS          0x40000000
 * 
 * I2C Wire;
 * setAddress(&Wire, ADDRESS);
 * end(&Wire);
 * 
 * @endcode
 * 
 */
void end(I2C *i2c_obj);


/**
 * @brief Este método inicializa el bloque IP del I2C.
 * 
 * @code 
 * 
 * #include "I2C.hpp"
 * 
 * #define ADDRESS          0x40000000
 * 
 * I2C Wire;
 * setAddress(&Wire, ADDRESS);
 * begin(&Wire);
 * 
 * @endcode
 * 
 */
void begin(I2C *i2c_obj);

/**
 * @brief Este método inicia el sistema de transmisión de datos al esclavo por
 * parte del maestro.
 * 
 * Tras este método se puede escribir tantos datos como se desee, hasta que
 * se utilice el método endTransmission().
 * 
 * @code 
 * 
 * #include "I2C.hpp"
 * 
 * #define ADDRESS          0x40000000
 * #define SLAVE_ADDRESS    0x68
 * #define DATA1            0x30
 * #define DATA2            0x00
 * 
 * I2C Wire;
 * setAddress(&Wire, ADDRESS);
 * begin(&Wire);
 * ...
 * beginTransmission(&Wire, SLAVE_ADDRESS);
 * write(&Wire, DATA1);
 * write(&Wire, DATA2);
 * endTransmission(&Wire);
 * 
 * @endcode
 * 
 * @param slave Dirección I2C del esclavo. Rango: [0, 127].
 */
void beginTransmission(I2C *i2c_obj, int slave);


/**
 * @brief Este método transmite al esclavo el dato de 8 bits deseado.
 * 
 * @note Se necesita previamente haber aplicado el método beginTransmission().
 * 
 * @code 
 * 
 * #include "I2C.hpp"
 * 
 * #define ADDRESS          0x40000000
 * #define SLAVE_ADDRESS    0x68
 * #define DATA1            0x30
 * #define DATA2            0x00
 * 
 * I2C Wire;
 * setAddress(&Wire, ADDRESS);
 * begin(&Wire);
 * ...
 * beginTransmission(&Wire, SLAVE_ADDRESS);
 * write(&Wire, DATA1);
 * write(&Wire, DATA2);
 * endTransmission(&Wire);
 * 
 * @endcode
 * 
 * 
 * @param data Dato de 8 bits a transmitir al esclavo.
 */
void write(I2C *i2c_obj, int data);

/**
 * @brief Este método finaliza el ciclo de transmisión de datos al esclavo.
 * 
 * @code 
 * 
 * #include "I2C.hpp"
 * 
 * #define ADDRESS          0x40000000
 * #define SLAVE_ADDRESS    0x68
 * #define DATA1            0x30
 * #define DATA2            0x00
 * 
 * I2C Wire;
 * setAddress(&Wire, ADDRESS);
 * begin(&Wire);
 * ...
 * beginTransmission(&Wire, SLAVE_ADDRESS);
 * write(&Wire, DATA1);
 * write(&Wire, DATA2);
 * endTransmission(&Wire);
 * 
 * @endcode
 * 
 */
void endTransmission(I2C *i2c_obj);

/**
 * @brief Este método solicita al bloque IP de leer los datos consecutivos por 
 * I2C al esclavo deseado.
 * 
 * Los datos leídos se guardan en un FIFO interno del bloque IP.
 * 
 * @code 
 * 
 * #include "I2C.hpp"
 * 
 * #define ADDRESS          0x40000000
 * #define SLAVE_ADDRESS    0x68
 * #define DATA1            0x30
 * #define DATA2            0x00
 * 
 * I2C Wire;
 * setAddress(&Wire, ADDRESS);
 * begin(&Wire);
 * ...
 * beginTransmission(&Wire, SLAVE_ADDRESS);
 * write(&Wire, DATA1);
 * write(&Wire, DATA2);
 * endTransmission(&Wire);
 * ...
 * requestFrom(&Wire, SLAVE_ADDRESS, 2);
 * 
 * @endcode
 * 
 * @param slave Dirección del esclavo I2C. Rango: [0, 127].
 * @param size Tamaño de datos a leer. Rango[1, 32].
 */
void requestFrom(I2C *i2c_obj, int slave, int size);

/**
 * @brief Este método solicita al bloque IP un dato leído.
 * 
 * El bloque IP desaloja los datos del FIFO por orden de llegada.
 * 
 * Si se excede el tamaño del FIFO se devuelve siempre el valor 0.
 * 
 * @code 
 * 
 * #include "I2C.hpp"
 * 
 * #define ADDRESS          0x40000000
 * #define SLAVE_ADDRESS    0x68
 * #define DATA1            0x30
 * #define DATA2            0x00
 * 
 * I2C Wire;
 * setAddress(&Wire, ADDRESS);
 * begin(&Wire);
 * ...
 * beginTransmission(&Wire, SLAVE_ADDRESS);
 * write(&Wire, DATA1);
 * write(&Wire, DATA2);
 * endTransmission(&Wire);
 * ...
 * requestFrom(&Wire, SLAVE_ADDRESS, 2);
 * int data[2];
 * data[0] = read(&Wire);
 * data[1] = read(&Wire);
 * 
 * @endcode
 * 
 * @return int Dato de 8 bits leído por I2C.
 */
int read(I2C *i2c_obj);


