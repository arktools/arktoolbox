n=x_choose([
'Linear Quadratic Output Feedback';
],'arktoolbox script demos');

if (n==1)
	exec(arktoolboxPath+'demos/script/linearQuadraticDemo.sce');
else
	disp('unknown demo');
end
