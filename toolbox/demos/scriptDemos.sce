n=x_choose([
'Linear Quadratic Output Feedback';
],'mavsim script demos')

if (n==1)
	exec(mavsimPath+'demos/script/linearQuadraticDemo.sce')
else
	disp('unknown demo')
end
