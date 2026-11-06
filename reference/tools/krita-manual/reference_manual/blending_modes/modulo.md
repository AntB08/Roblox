## Modulo 

Modulo modes are a special class of blending modes which loop values when the value of the channel blend layer is less than the value of the channel in base layers. All modes in modulo modes retains the absolute of the remainder if the value is greater than the maximum value or the value is less than minimum value. Continuous modes assume if the calculated value before modulo operation is within the range between a odd number to even number, then values are inverted in the end result, so values are perceived to be wave-like. 

Furthermore, this would imply that modulo modes are beneficial for abstract art, and manipulation of gradients.  

### Divisive Modulo 

First, the base layer is divided by the sum of blend layer and the minimum possible value after zero. Then, performs a modulo calculation using the value found with the sum of the blend layer and the minimum possible value after zero.  [img: ../../_images/Blending_modes_Divisive_Modulo_Gradient_Comparison.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **Divisive Modulo**.     

### Divisive Modulo - Continuous 

First, base layer is divided by the sum of the blend layer and the minimum possible value after zero. Then, performs a modulo calculation using the value found with the sum of the blend layer and the minimum possible value after zero. As this is a continuous mode, anything between odd to even numbers are inverted.  [img: ../../_images/Blending_modes_Divisive_Modulo_Continuous_Gradient_Comparison.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **Divisive Modulo - Continuous**.     

### Modulo 

Performs a modulo calculation using the sum of the blend layer and the minimum possible value after zero.  [img: ../../_images/Blending_modes_Modulo_Gradient_Comparison.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **Modulo**.     

### Modulo - Continuous 

Performs a modulo calculation using the sum of the blend layer and the minimum possible value after zero. As this is a continuous mode, anything between odd to even numbers are inverted.  [img: ../../_images/Blending_modes_Modulo_Continuous_Gradient_Comparison.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **Modulo - Continuous**.     

### Modulo Shift 

Performs a modulo calculation with the result of the sum of the base and blend layers by the sum of the blend layer with the minimum possible value after zero.  [img: ../../_images/Blending_modes_Modulo_Shift_Gradient_Comparison.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **Modulo Shift**.     

### Modulo Shift - Continuous 

Performs a modulo calculation with the result of the sum of the base and blend layers by the sum of the blend layer with the minimum possible value after zero. As this is a continuous mode, anything between odd to even numbers are inverted.  [img: ../../_images/Blending_modes_Modulo_Shift_Continuous_Gradient_Comparison.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **Modulo Shift - Continuous**.