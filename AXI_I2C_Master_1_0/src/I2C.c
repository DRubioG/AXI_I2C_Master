#include "I2C.h"


void setAddress(I2C *i2c_obj, uint32_t address){
    i2c_obj->_address = address;
}

// Este método finaliza la operación del bloque IP del I2C.
void end(I2C *i2c_obj){
    uint32_t address = i2c_obj->_address;

    uint32_t reg = Xil_In32(address+CNTRL_REG);
    // Poner a '0' el valor del registro.
    Xil_Out32(address+CNTRL_REG, reg & ~( 1<< EN_POS));
}

// Este método inicializa el bloque IP del I2C.
void begin(I2C *i2c_obj){
    uint32_t address = i2c_obj->_address;

    uint32_t reg = Xil_In32(address+CNTRL_REG);
    // Poner a '1' el valor del registro.
    Xil_Out32(address+CNTRL_REG, reg | ( 1<< EN_POS));
}

// Este método inicia el sistema de transmisión de datos al esclavo por parte del maestro.
void beginTransmission(I2C *i2c_obj, int slave){
    uint32_t address = i2c_obj->_address;
    
    // Selecciona el esclavo en el que se va a escribir.
    Xil_Out32(address+WRITE_REG, slave);
}

// Este método transmite al esclavo el dato de 8 bits deseado.
void write(I2C *i2c_obj, int data){
    uint32_t address = i2c_obj->_address;
    

    uint32_t reg = Xil_In32(address+WRITE_REG);
    // Escribe el valor en el registro de escritura.
    Xil_Out32(address+WRITE_REG, reg | (data < DATA_POS));

    reg = Xil_In32(address+CNTRL_REG);
    // Manda la señal de envío al bloque IP.
    Xil_Out32(address+CNTRL_REG, reg | ( 1<< ST_POS));
    // Borra la señal de envío al bloque IP.
    Xil_Out32(address+CNTRL_REG, reg & ~( 1<< ST_POS));
}

// Este método finaliza el ciclo de transmisión de datos al esclavo.
void endTransmission(I2C *i2c_obj){
    uint32_t address = i2c_obj->_address;
    

    uint32_t reg = Xil_In32(address+CNTRL_REG);
    // Emite la orden de finalizar el bloque IP.
    Xil_Out32(address+CNTRL_REG, reg | ( 1<< SP_POS));
    // Borra la orden de finalizar el bloque IP.
    Xil_Out32(address+CNTRL_REG, reg & ~( 1<< SP_POS));
}

//Este método solicita al bloque IP de leer los datos consecutivos por I2C al esclavo deseado.
void requestFrom(I2C *i2c_obj, int slave, int size){
    uint32_t address = i2c_obj->_address;
    

    // Comprueba que el tamaño no exceda el límite del FIFO.
    if((size > 32) && (size < 0))
        return;

    
    uint32_t reg = Xil_In32(address+CNTRL_REG);
    // Esritura del tamaño a leer
    Xil_Out32(address+CNTRL_REG, reg | ( size<< SIZE_POS));


    reg = Xil_In32(address+CNTRL_REG);
    // Manda la orden de lectura 
    Xil_Out32(address+CNTRL_REG, reg | ( 1<< READ_POS));
    // Borra la orden de lectura
    Xil_Out32(address+CNTRL_REG, reg & ~( 1<< READ_POS));


}

// Este método solicita al bloque IP un dato leído.
int read(I2C *i2c_obj){
    uint32_t address = i2c_obj->_address;
    
    uint32_t reg = Xil_In32(address+READ_REG);

    // Devuelve el dato leído del FIFO
    int data = (int)((reg >> READ_POS) & 0xFF);

    // Manda la orden de actualización del dato del FIFO.
    Xil_Out32(address+CNTRL_REG, reg | ( 1<< FF_POS));
    // Borra la orden de actualización
    Xil_Out32(address+CNTRL_REG, reg & ~( 1<< FF_POS));

    // Dato del FIFO
    return data;
}
