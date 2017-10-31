# ex_dynamicinput
Example of some of the potential uses of Dynamic Dialog for variable length forms

This program first has a window that prompts you for
a) the total number of fields
b) the total number of columns
c) a boolean to indicate if pages should be used
d) number of elements on the page

The default values have page mode disabled.  This will simply display and allow input on a form with the chosen number of fields and columns, so with default values of 12 and 3, show 12 fields in 3 columns.  

<img alt="12 fields, 3 columns" src="https://user-images.githubusercontent.com/13615993/32220923-60db1a0a-be98-11e7-90cf-52b496458d2e.png" width="50%" />

Change the number of columns to 2 or 4, and note the change in appearance of the form.

<img alt="12 fields, 4 columns" src="https://user-images.githubusercontent.com/13615993/32220921-60a61dbe-be98-11e7-8573-cbd690859404.png" width="50%" />

Change the page mode checkbox and display the form again, and the maximum number of fields shown on the form will be limited, and will display some additional buttons along the button that allows you to navigate to a certain page.  

<img alt="12 fields, 3 columns, 6 to a page" src="https://user-images.githubusercontent.com/13615993/32220920-606ee54c-be98-11e7-8a79-df62c8864c33.png" width="50%" />

Experiment changing the total number of fields and total number of rows on the form.

This is using dynamic dialogs to generate a dialog with a variable number of fields, if page mode is enabled, it will also add a variable number of buttons for each page.  It also illustrates techniques used to generate a form dynamically.



