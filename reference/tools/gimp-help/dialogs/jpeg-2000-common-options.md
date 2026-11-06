ICT compression

 When checked, ICT (Irreversible Color Transform) compression will be
 used instead of RCT (Reversible Color Transform).
 ICT can cause rounding errors, which means it is lossy, contrary to
 RCT.

 Number of resolutions

 Set this to the number of resolutions you want to be stored in your
 image. This adds reduced size images for faster loading.

 Progression order

 This defines how image data is organized in the JPEG 2000 codestream,
 allowing you to prioritize progressive viewing by quality, resolution
 or component.
 The letters stand for Layer, Resolution, Component, Position.

 LRCP

 The default.
 Shows quality layers first, then resolution, then components,
 then spatial positions (good for gradual quality increase).

 RLCP

 Shows all data for the lowest resolution, then adds layers, then
 moves to the next resolution level.

 PCRL

 Shows full resolution tiles first, then fills in layers, good
 for fast preview.

 RPCL

 Focuses on spatial detail within a tile first.

 CPRL

 Focuses on full data for one component before moving to the next.

 Compliance profile

 Select the compliance profile you require for your image.

 Standard Profile

 The default conforms to the basic standard functionality for
 JPEG 2000 images.

 Cinema2K (24 FPS)

 Generates a codestream compliant with the Digital Cinema
 Specifications for 2K resolution content at 24 FPS.

 Cinema2K (48 FPS)

 Generates a codestream compliant with the Digital Cinema
 Specifications for 2K resolution content at 48 FPS.

 Cinema4K (24 FPS)

 Generates a codestream compliant with the Digital Cinema
 Specifications for 4K resolution content at 24 FPS.