function plps_scroll_wheel
% Illustrates how to use WindowScrollWheelFcn property
%
   f = figure('WindowScrollWheelFcn',@figScroll,'Name','polar log phase screen Demo');
   
   l0 = single( 1e-3 );
   L  = single( 1e2 );
   L0 = single( 30 );
   f = L/l0;
   delta = 20/100;
   kmin = 2*pi/L;
   
   N_k = log(f)/log( (2+delta)/(2-delta) );
   N_a = 0.25*pi*( (f^(1/N_k) + 1)/(f^(1/N_k) - 1) );
   
   N_k = 2^nextpow2(N_k);
   N_a = 2^nextpow2(N_a);
   
   f = single( ( (4*N_a + pi)/(4*N_a - pi) )^N_k );
   delta = single( 0.5*pi/N_a );
   
   L = f*l0;
   kmin = 2*pi/L;
   
   r0 = 10e-2;
   
   D = 2*L0;
   gpuKern = parallel.gpu.CUDAKernel('plps.ptx','plps.cu','plps');
   gpuKern.ThreadBlockSize = ones(1,2)*16;

   N_k = single( N_k );
   N_a = single( N_a );
   
   zeta1 = sqrt( -log(gpuArray.rand(N_k,N_a,'single') ) );
   eta1  = 2*pi*gpuArray.rand(N_k,N_a,'single');
   zeta2 = sqrt( -log(gpuArray.rand(N_k,N_a,'single') ) );
   eta2  = 2*pi*gpuArray.rand(N_k,N_a,'single');
   
   nxy = 500;
   gpuKern.GridSize = double( ones(1,2)*ceil(nxy/16) );
   u = 0.5*D*single(gpuArray.linspace(-1,1,nxy));
   [x,y] = meshgrid(u);
   phs = gpuArray.zeros(nxy,'single');
   
   phs = feval(gpuKern,phs,x,y,nxy^2,N_k,N_a,f,delta,L0,r0,kmin,zeta1,eta1,zeta2,eta2);

   a = axes; 
   h = imagesc(u,u,phs);
   axis square
   colorbar
   title('Rotate the scroll wheel')
   
   atm = atmosphere(photometry.V,r0,L0);
   phaseStats.variance(atm)
   set(a,'clim',[-1,1]*sqrt(phaseStats.variance(atm))*2.5)
   
   function figScroll(src,evnt)
      if evnt.VerticalScrollCount > 0 
         D = D*1.25;
         re_eval()
      elseif evnt.VerticalScrollCount < 0 
         D = D*0.75;
         re_eval()
      end
   end %figScroll

    function re_eval
        
        nxy = 500;
        gpuKern.GridSize = double( ones(1,2)*ceil(nxy/16) );
        u = 0.5*D*single(gpuArray.linspace(-1,1,nxy));
        [x,y] = meshgrid(u);
        phs = gpuArray.zeros(nxy,'single');
        
        phs = feval(gpuKern,phs,x,y,nxy^2,N_k,N_a,f,delta,L0,r0,kmin,zeta1,eta1,zeta2,eta2);
        
        d_u = gather(u);
        set(h,'xData',d_u,'yData',d_u,'CData',gather(phs))
        lim = [-1,1]*0.5*D;
        set(a,'xlim',lim,'ylim',lim)
        drawnow
    end % re_eval
end % scroll_wheel