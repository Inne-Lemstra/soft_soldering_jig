
## Differences between versions

### V0
A minimal prototype containig 1 plaza surounded by 4 buildings. Mold consists of two parts. 
A cylinder containing most of the topology and a plug for making the hole the air tube needs.
Plug connects to the cylinder manking the manhole.

### V1
First actual size version of jig and mold. Cylindrical city with diameter of 10cm. Poles to create manholes are printed on the top mold. These are very thin an might break easily depending on extruder head filement size etc.
Underground foundation is based on underground water reservoirs that some Japanese cities have. (Actually they are a kind of flood protection, forming a basin where flooded river water can drain too.) Foundation is placed under buildings, this to create a air resevoir for pulling a draft/vacuum on the manholes keeping parts in place.

### V2
Continuation of V1, manholes are now made by inserting brass ronds into the top mold after printing.
This should make it possible to create smaller manholes and sturdier molds (which also helps with demolding).

## Description of modules

### render settings
Modules with the expres purpose to finetune what is being rendered
#### make\_model() 
Coupled to the render\_jig variable
##### make\_above\_ground()
Generate everything above the z plane, as it should look in the final silicone cast. 
##### make\_underground() 
Generate everything below the z plane, representing the final silicone cast.

#### make\_mold()
Coupled with render\_mold variable
##### mold\_above\_ground()
Generate the mold for casting silicone in, negative of model (make\_above\_ground) plus tweaks.
##### mold\_underground() 
Generate the mold for casting silicone in, negative of model (make\_above\_ground) plus tweaks.

### shapes
Basic shapes made with the variables set globally
#### plaza(center = false) 
#### building() 
#### make\_wall() 
#### drain\_pipe() 
#### bedrock() 

### operations
Change/move shapes or generate multiple shapes at the same time.
#### grid\_to\_origin() 
#### move\_to\_crossroad() 
#### cylinder\_to\_building() 
#### make\_grid(allow\_outside\_city = true, w\_boundries = [0,0]) 
#### foundation() 
#### make\_drainage() 
#### location\_drainage() 
#### mold\_combine\_tube() 
#### mold\_drainage() 
#### area\_cross\_section(angle = 60) 
