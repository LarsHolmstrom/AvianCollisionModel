

%Should just collide at x=y=0
x_1 = -1;
y_1 = -1;
x_2 = 1;
y_2 = 1;
x_3 = 1;
y_3 = -1;
x_4 = -1;
y_4 = 1;

[collided x_c y_c] = PassBehind(x_1, y_1, ...
                                x_2, y_2, ...
                                x_3, y_3, ...
                                x_4, y_4)
                  
%Should be false
x_1 = -1;
y_1 = -1;
x_2 = 2;
y_2 = 2;
x_3 = 1;
y_3 = -1;
x_4 = -1;
y_4 = 1;

[collided x_c y_c] = PassBehind(x_1, y_1, ...
                                x_2, y_2, ...
                                x_3, y_3, ...
                                x_4, y_4)
                  
%Should be true
x_1 = -1;
y_1 = -1;
x_2 = 1;
y_2 = 1;
x_3 = 1;
y_3 = -1;
x_4 = -2;
y_4 = 2;

[collided x_c y_c] = PassBehind(x_1, y_1, ...
                                x_2, y_2, ...
                                x_3, y_3, ...
                                x_4, y_4)   