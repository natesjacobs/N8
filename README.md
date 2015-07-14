# N8
Process, analyze, and visualize space-time series data stored in single 8D array:

Dimension 1 - Space (x)

Dimension 2 - Space (y)

Dimension 3 - Space (z - depth)

Dimension 4 - Time

Dimension 5 - Other (condition)

Dimension 6 - Other (subject)

Dimension 7 - Other (trial)

Dimension 8 - Other (channel/n-trode)




Any script starting with "n8" are able to handle 8D arrays as inputs. Any script starting with "n8load_" is for loading file(s) into 8D array. Data is stored in structure array called DATA (for example, DATA.MyData). Notes and other information is stored in structure array called NOTES (for example, NOTES.SampleRate). Both DATA and NOTES are global variables that can be called from any function.


