function [A,B] = sigmoidPlatt(out,target,prior1,prior0)

A = 0;
B = log((prior0+1)/(prior1+1));
hiTarget = (prior1+1)/(prior1+2);
loTarget = 1/(prior0+2);
lambda = 1e-3;
olderr = 1e300;
numOfSamples = length(target);
pp = zeros(numOfSamples,1) + ((prior1+1)/(prior0+prior1+2));
count = 0;
for it = 1:100
	a = 0; b = 0; c = 0; d = 0; e = 0;
	for i = 1:numOfSamples
		if( target(i) )
			t = hiTarget;
		else
			t = loTarget;
		end;
		d1 = pp(i)-t;
		d2 = pp(i)*(1-pp(i));
		a = a + out(i)*out(i)*d2;
		b = b + d2;
		c = c + out(i)*d2;
		d = d + out(i)*d1;
		e = e + d1;
	end;
	if( (abs(d)<1e-9) && (abs(e)<1e-9) )
		break;
	end;
	oldA = A;
	oldB = B;
	err = 0;

	while( 1 )
		det = ((a+lambda)*(b+lambda)) - (c*c);
		if( det==0 )
			lambda = lambda*10;
			continue;
		end;
		A = oldA + ((b+lambda)*d-c*e)/det;
		B = oldB + ((a+lambda)*e-c*d)/det;

		err = 0;
		for i = 1:numOfSamples
			p = 1/(1+exp(out(i)*A+B));
			pp(i) = p;
			err = err - t*log(p) + (1-t)*log(1-p);
		end;
		if( err < olderr*(1+1e-7) )
			lambda = lambda*0.1;
			break;
		end;

		lambda = lambda*10;
		if( lambda>=1e6 )
			break;
		end;
	end;
	diff = err - olderr;
	scale = 0.5*(err+olderr+1);
	if( (diff > -1e-3*scale) && (diff < 1e-7*scale) )
		count = count + 1;
	else
		count = 0;
	end;
	olderr = err;
	if( count==3 )
		break;
	end;
end;

