n=x_choose([
'Linear Quadratic Output Feedback';
],'arkscicos script demos');

if (n==1)
	exec(arkscicosPath+'demos/script/linearQuadraticDemo.sce');
else
	disp('unknown demo');
end
