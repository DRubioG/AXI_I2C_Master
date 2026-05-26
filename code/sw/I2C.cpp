#include "I2C.hpp"


// Constructor de la clase I2C.
I2C::I2C(uint32_t address)
{
    // Asignación de la propiedad _address.
    _address = address;
}

// Destructor de la clase.
I2C::~I2C()
{
}


// Este método finaliza la operación del bloque IP del I2C.
void I2C::end(){
    // Lectura del valor del registro.
    uint32_t reg = Xil_In32(_address+CNTRL_REG);
    // Poner a '0' el valor del registro.
    Xil_Out32(_address+CNTRL_REG, reg & ~( 1<< EN_POS));
}

// Este método inicializa el bloque IP del I2C.
void I2C::begin(){
    // Lectura del valor del registro.
    uint32_t reg = Xil_In32(_address+CNTRL_REG);
    // Poner a '1' el valor del registro.
    Xil_Out32(_address+CNTRL_REG, reg | ( 1<< EN_POS));
}

// Este método inicia el sistema de transmisión de datos al esclavo por parte del maestro.
I2C_Response I2C::beginTransmission(int slave){
    // Selecciona el esclavo en el que se va a escribir.
    Xil_Out32(_address+WRITE_REG, slave);
    
    int err = (Xil_In32(_address+READ_REG)>>8)&0x1;
    if(err == 1){
        return NO_PASS;
    }else{
        return PASS;
    }

}

// Este método transmite al esclavo el dato de 8 bits deseado.
int I2C::write(int data){
    // Lectura del valor del registro.
    uint32_t reg = Xil_In32(_address+WRITE_REG);
    // Escribe el valor en el registro de escritura.
    Xil_Out32(_address+WRITE_REG, reg | (data < DATA_POS));

    // Lectura del valor del registro.
    reg = Xil_In32(_address+CNTRL_REG);
    // Manda la señal de envío al bloque IP.
    Xil_Out32(_address+CNTRL_REG, reg | ( 1<< ST_POS));
    // Borra la señal de envío al bloque IP.
    Xil_Out32(_address+CNTRL_REG, reg & ~( 1<< ST_POS));

    // int err = (Xil_In32(_address+READ_REG)>>8)&0x1;
    // if(err == 1){
    //     return NO_PASS;
    // }else{
    //     return PASS;
    // }
    return 0;
}

// Este método finaliza el ciclo de transmisión de datos al esclavo.
void I2C::endTransmission(){
    // Lectura del valor del registro.
    uint32_t reg = Xil_In32(_address+CNTRL_REG);
    // Emite la orden de finalizar el bloque IP.
    Xil_Out32(_address+CNTRL_REG, reg | ( 1<< SP_POS));
    // Borra la orden de finalizar el bloque IP.
    Xil_Out32(_address+CNTRL_REG, reg & ~( 1<< SP_POS));
}

//Este método solicita al bloque IP de leer los datos consecutivos por I2C al esclavo deseado.
I2C_Response I2C::requestFrom(int slave, int size){

    // Comprueba que el tamaño no exceda el límite del FIFO.
    if((size > 32) && (size < 0))
        return NO_PASS;

    
    // Lectura del valor del registro.
    uint32_t reg = Xil_In32(_address+CNTRL_REG);
    // Esritura del tamaño a leer
    Xil_Out32(_address+CNTRL_REG, reg | ( size<< SIZE_POS));


    // Lectura del valor del registro.
    reg = Xil_In32(_address+CNTRL_REG);
    // Manda la orden de lectura 
    Xil_Out32(_address+CNTRL_REG, reg | ( 1<< READ_POS));
    // Borra la orden de lectura
    Xil_Out32(_address+CNTRL_REG, reg & ~( 1<< READ_POS));

    return PASS;

}

// Este método solicita al bloque IP un dato leído.
int I2C::read(){
    // Lectura del valor del registro.
    uint32_t reg = Xil_In32(_address+READ_REG);

    // Devuelve el dato leído del FIFO
    int data = static_cast<int>((reg >> READ_POS) & 0xFF);

    // Manda la orden de actualización del dato del FIFO.
    Xil_Out32(_address+CNTRL_REG, reg | ( 1<< FIFO_POS));
    // Borra la orden de actualización
    Xil_Out32(_address+CNTRL_REG, reg & ~( 1<< FIFO_POS));

    // Dato del FIFO
    return data;
}
