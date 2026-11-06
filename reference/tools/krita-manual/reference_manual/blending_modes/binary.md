## Binary 

Binary modes are a special class of blending modes which utilize binary operators for calculations. Binary modes are unlike every other blending modes as these modes have a fractal attribute with falloff similar to other blending modes. Binary modes can be used for generation of abstract art using layers with very smooth surfaces. All binary modes have capitalized letters to distinguish themselves from other blending modes. 

To clarify on how binary modes work, convert decimal values to binary values, then treat 1 or 0 as T or F respectively, and use binary operation to get the end result, and then convert the result back to decimal. 

 

Warning 

Binary blending modes do not work on float images or negative numbers! So, don’t report bugs about using binary modes on unsupported color spaces.   

### AND 

Performs the AND operation for the base and blend layer. Similar to multiply blending mode.  [img: ../../_images/Blend_modes_AND_map.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **AND**.    [img: ../../_images/Blending_modes_AND_Gradients.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **AND**.     

### CONVERSE 

Performs the inverse of IMPLICATION operation for the base and blend layer. Similar to screen mode with blend layer and base layer inverted.  [img: ../../_images/Blend_modes_CONVERSE_map.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **CONVERSE**.    [img: ../../_images/Blending_modes_CONVERSE_Gradients.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **CONVERSE**.     

### IMPLICATION 

Performs the IMPLICATION operation for the base and blend layer. Similar to screen mode with base layer inverted.  [img: ../../_images/Blend_modes_IMPLIES_map.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **IMPLICATION**.    [img: ../../_images/Blending_modes_IMPLIES_Gradients.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **IMPLICATION**.     

### NAND 

Performs the inverse of AND operation for base and blend layer. Similar to the inverted multiply mode.  [img: ../../_images/Blend_modes_NAND_map.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **NAND**.    [img: ../../_images/Blending_modes_NAND_Gradients.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **NAND**.     

### NOR 

Performs the inverse of OR operation for base and blend layer. Similar to the inverted screen mode.  [img: ../../_images/Blend_modes_NOR_map.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **NOR**.    [img: ../../_images/Blending_modes_NOR_Gradients.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **NOR**.     

### NOT CONVERSE 

Performs the inverse of CONVERSE operation for base and blend layer. Similar to the multiply mode with base layer and blend layer inverted.  [img: ../../_images/Blend_modes_NOT_CONVERSE_map.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **NOT CONVERSE**.    [img: ../../_images/Blending_modes_NOT_CONVERSE_Gradients.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **NOT CONVERSE**.     

### NOT IMPLICATION 

Performs the inverse of IMPLICATION operation for base and blend layer. Similar to the multiply mode with the blend layer inverted.  [img: ../../_images/Blend_modes_NOT_IMPLICATION_map.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **NOT IMPLICATION**.    [img: ../../_images/Blending_modes_NOT_IMPLICATION_Gradients.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **NOT IMPLICATION**.     

### OR 

Performs the OR operation for base and blend layer. Similar to screen mode.  [img: ../../_images/Blend_modes_OR_map.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **OR**.    [img: ../../_images/Blending_modes_OR_Gradients.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **XOR**.     

### XOR 

Performs the XOR operation for base and blend layer. This mode has a special property that if you duplicate the blend layer twice, you get the base layer.  [img: ../../_images/Blend_modes_XOR_map.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **XOR**.    [img: ../../_images/Blending_modes_XOR_Gradients.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **XOR**.     

### XNOR 

Performs the XNOR operation for base and blend layer. This mode has a special property that if you duplicate the blend layer twice, you get the base layer.  [img: ../../_images/Blend_modes_XNOR_map.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **XNOR**.    [img: ../../_images/Blending_modes_XNOR_Gradients.png]  

Left: **Base Layer**. Middle: **Blend Layer**. Right: **XNOR**.