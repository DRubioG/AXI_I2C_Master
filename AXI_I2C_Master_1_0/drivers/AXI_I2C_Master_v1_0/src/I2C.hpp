/**
 * @file I2C.hpp
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

class I2C
{
private:
    /* data */
    uint32_t _address;
public:
/**
 * @brief Constructor de la clase I2C.
 * 
 * @param address Dirección del bloque IP en memoria.
 */
    I2C(uint32 address);

/**
 * @brief Destructor de la clase.
 * 
 */
    ~I2C();

/**
 * @brief Este método finaliza la operación del bloque IP del I2C.
 * 
 * @code 
 * 
 * #include "I2C.hpp"
 * 
 * #define ADDRESS          0x40000000
 * 
 * I2C Wire(ADDRESS);
 * I2C.end();
 * 
 * @endcode
 * 
 */
    void end();

/**
 * @brief Este método inicializa el bloque IP del I2C.
 * 
 * @code 
 * 
 * #include "I2C.hpp"
 * 
 * #define ADDRESS          0x40000000
 * 
 * I2C Wire(ADDRESS);
 * I2C.begin();
 * 
 * @endcode
 * 
 */
    void begin();

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
 * I2C Wire(ADDRESS);
 * I2C.begin();
 * ...
 * Wire.beginTransmission(SLAVE_ADDRESS);
 * Wire.write(DATA1);
 * Wire.write(DATA2);
 * Wire.endTransmission();
 * 
 * @endcode
 * 
 * @param slave Dirección I2C del esclavo. Rango: [0, 127].
 * @return Error en la comunicación. Si el valor devuelto es 1, se ha producido
 * un error en la comunicación. Si es 0, la comunicación ha sido correcta.
 */
    int beginTransmission(int slave);


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
 * I2C Wire(ADDRESS);
 * I2C.begin();
 * ...
 * Wire.beginTransmission(SLAVE_ADDRESS);
 * Wire.write(DATA1);
 * Wire.write(DATA2);
 * Wire.endTransmission();
 * 
 * @endcode
 * 
 * 
 * @param data Dato de 8 bits a transmitir al esclavo.
 * @return Error en la comunicación. Si el valor devuelto es 1, se ha producido
 * un error en la comunicación. Si es 0, la comunicación ha sido correcta.
 */
    int write(int data);

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
 * I2C Wire(ADDRESS);
 * I2C.begin();
 * ...
 * Wire.beginTransmission(SLAVE_ADDRESS);
 * Wire.write(DATA1);
 * Wire.write(DATA2);
 * Wire.endTransmission();
 * 
 * @endcode
 * 
 */
    void endTransmission();

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
 * I2C Wire(ADDRESS);
 * I2C.begin();
 * ...
 * Wire.beginTransmission(SLAVE_ADDRESS);
 * Wire.write(DATA1);
 * Wire.write(DATA2);
 * Wire.endTransmission();
 * ...
 * Wire.requestFrom(SLAVE_ADDRESS, 2);
 * 
 * @endcode
 * 
 * @param slave Dirección del esclavo I2C. Rango: [0, 127].
 * @param size Tamaño de datos a leer. Rango[1, 32].
 * @return Error en la comunicación. Si el valor devuelto es 1, se ha producido
 * un error en la comunicación. Si es 0, la comunicación ha sido correcta.
 */
    int requestFrom(int slave, int size);

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
 * I2C Wire(ADDRESS);
 * I2C.begin();
 * ...
 * Wire.beginTransmission(SLAVE_ADDRESS);
 * Wire.write(DATA1);
 * Wire.write(DATA2);
 * Wire.endTransmission();
 * ...
 * Wire.requestFrom(SLAVE_ADDRESS, 2);
 * int data[2];
 * data[0] = Wire.read();
 * data[1] = Wire.read();
 * 
 * @endcode
 * 
 * @return int Dato de 8 bits leído por I2C.
 */
    int read();

};

