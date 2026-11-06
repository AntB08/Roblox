## 
 The Script-Fu parameter API
 This section is not part of the original tutorial.

 Beside the above parameter types there are more types for the
 interactive mode, each of them will create a widget in the control
 dialog. You will find a list of these parameters with descriptions and
 examples in the test script
 plug-ins/script-fu/scripts/test-sphere-v3.scm
 shipped with the GIMP source code.

Param Type

Description

SF-ADJUSTMENT

 Creates an adjustment widget in the dialog.

 SF-ADJUSTMENT "label" '(value lower upper step_inc page_inc
 digits type)

## Widget arguments list

 Element
 Description

 "label"
 Text printed before the widget.

 value
 Value print at the start.

 lower / upper
 The lower / upper values (range of choice).

 step_inc
 Increment/decrement value.

 page_inc
 Increment/decrement value using page key.

 digits
 Digits after the point (decimal part).

 type
 One of: SF-SLIDER or 0, SF-SPINNER or 1

SF-COLOR

Creates a color button in the dialog.

SF-COLOR "label" '(red green blue)

or

SF-COLOR "label" "color"

## Widget arguments list

 Element
 Description

 "label"
 Text printed before the widget.

 '(red green blue)

 List of three values for the red, green and blue components.

 "color"
 Color name in CSS notation.

SF-FONT

 Creates a font-selection widget in the dialog. It returns a
 fontname as a string. There are two new gimp-text procedures to
 ease the use of this return parameter:

 (gimp-text-fontname image drawable x-pos y-pos text border
 antialias size unit font)

 (gimp-text-get-extents-fontname text size unit font)

 where font is the fontname you get. The size specified in the
 fontname is silently ignored. It is only used in the
 font-selector. So you are asked to set it to a useful value (24
 pixels is a good choice).

SF-FONT "label" "fontname"

## Widget arguments list

 Element
 Description

 "label"
 Text printed before the widget.

 "fontname"
 Name of the default font.

SF-BRUSH

 It will create a widget in the control dialog. The widget
 consists of a preview area (which when pressed will produce a
 popup preview ) and a button with the "..." label. The button
 will popup a dialog where brushes can be selected and each of
 the characteristics of the brush can be modified.

SF-BRUSH "Brush" '("Circle (03)" 100 44 0)

 Here the brush dialog will be popped up with a default brush of
 Circle (03) opacity 100 spacing 44 and paint mode of Normal
 (value 0).

 If this selection was unchanged the value passed to the function
 as a parameter would be '("Circle (03)" 100 44 0).

SF-PATTERN

 It will create a widget in the control dialog. The widget
 consists of a preview area (which when pressed will produce a
 popup preview ) and a button with the "..." label. The button
 will popup a dialog where patterns can be selected.

SF-PATTERN "Pattern" "Maple Leaves"

 The value returned when the script is invoked is a string
 containing the pattern name. If the above selection was not
 altered the string would contain "Maple Leaves".

SF-GRADIENT

 It will create a widget in the control dialog. The widget
 consists of a button containing a preview of the selected
 gradient.

 If the button is pressed a gradient selection dialog will popup.

SF-GRADIENT "Gradient" "Deep Sea"

 The value returned when the script is invoked is a string
 containing the gradient name. If the above selection was not
 altered the string would contain "Deep Sea".

SF-PALETTE

 It will create a widget in the control dialog. The widget
 consists of a button containing the name of the selected
 palette.

 If the button is pressed a palette selection dialog will popup.

SF-PALETTE "Palette" "Named Colors"

 The value returned when the script is invoked is a string
 containing the palette name. If the above selection was not
 altered the string would contain "Named Colors".

SF-FILENAME

 It will create a widget in the control dialog. The widget
 consists of a button containing the name of a file.

 If the button is pressed a file selection dialog will popup.

 SF-FILENAME "label" (string-append ""
 gimp-data-directory "/scripts/beavis.jpg")

 The value returned when the script is invoked is a string
 containing the filename.

SF-DIRNAME

 Only useful in interactive mode. Very similar to SF-FILENAME,
 but the created widget allows to choose a directory instead of a
 file.

 SF-DIRNAME "label" "/var/tmp/images"

 The value returned when the script is invoked is a string
 containing the dirname.

SF-OPTION

 It will create a widget in the control dialog. The widget is a
 combo-box showing the options that are passed as a list.

The first option is the default choice.

 SF-OPTION "label" '("option1" "option2")

 The value returned when the script is invoked is the number of
 the chosen option, where the option first is counted as 0.

SF-ENUM

 It will create a widget in the control dialog. The widget is a
 combo-box showing all enum values for the given enum type. This
 has to be the name of a registered enum, without the "Gimp"
 prefix. The second parameter specifies the default value, using
 the enum value's nick.

 SF-ENUM "Interpolation" '("InterpolationType" "linear")

 The value returned when the script is invoked corresponds to
 chosen enum value.