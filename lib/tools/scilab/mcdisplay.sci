// Dummy functions for doing scilab mcdisplay....
global INSTRUMENT;
INSTRUMENT=struct();
INSTRUMENT.name=[];
INSTRUMENT.transformation=[];
INSTRUMENT.coords=[];
INSTRUMENT.Ncnt=0;
INSTRUMENT.stop=0;
INSTRUMENT.read=0;
INSTRUMENT.Neutrons=[];
INSTRUMENT.Neutrons=list();
INSTRUMENT.Traced=0;
global component;
global coordinates;
global listcnt;

function setcomponent(mycomp)
  global component;
  global INSTRUMENT;
  component=mycomp;
  execstr(strcat(['INSTRUMENT.' component '=[];']));
  execstr(strcat(['INSTRUMENT.' component '=struct()']));
  INSTRUMENT.name=[INSTRUMENT.name component];
endfunction


function bool=isfield(List,Field)
  // Try getting the field:
  ierr=execstr('getfield(Field,List)','errcatch');
  if ierr==0
    bool=1;
  else
    bool=0;
  end
endfunction

function setposition(T)
  global INSTRUMENT
  global component
  T=([T(4:3:10) T(1);T(5:3:11) T(2);T(6:3:12) T(3);0 0 0 1]);
  tmp=['INSTRUMENT.' component '.T=T'];
  execstr(strcat(tmp));
endfunction

function multiline(coords)
  global INSTRUMENT
  global component
  global coordinates
  global listcnt
  listcnt=listcnt+1;  
  x=coords(2:3:length(coords));
  y=coords(3:3:length(coords));
  z=coords(4:3:length(coords));
  coords=[x;y;z;1+0*z];
  coordinates(listcnt)=coords;
  tmp=['INSTRUMENT.' component '.K=[]'];
  execstr(strcat(tmp));
  tmp=['INSTRUMENT.' component '.K=coordinates'];
  execstr(strcat(tmp)); 
  tmp=['INSTRUMENT.' component '.n=listcnt'];
  execstr(strcat(tmp));
endfunction

function invbool=not(var)
// invert boolean 
  invbool=~var;
endfunction

function bool=isempty(var)
// Checks if var is empty (matrix)
  if (var==[])
    bool=1;
  else
    bool=0;
  end
endfunction

function String=num2str(Number)
// Function for doing number to string translation
String=string(Number);
endfunction

function bool=strmatch(long_string,short_string)
// Find possible occurencies of short_string in long_string
  if length(long_string)>=length(short_string)
    idx=strindex(long_string,short_string);
    if isempty(idx)
      bool=0;
    else
      bool=1;
    end
  else
    bool=strmatch(short_string,long_string);
  end
endfunction

function bool=strsame(string1,string2)
// Are two strings the same?
  if length(string1)==length(string2)
    if length(string1)==0
      bool=1;
    else
      bool=strmatch(string1,string2);
    end
  else
    bool=0
  end
endfunction

function parmwin(varargin)
global INSTRUMENT
lab=["First component","Last component",...     
	"# neutrons to trace",...
	"alpha","theta","Exit"];
list1=list(lab(1),INSTRUMENT.FirstView,INSTRUMENT.name);
list2=list(lab(2),INSTRUMENT.LastView,INSTRUMENT.name);
list3=list(lab(3),INSTRUMENT.DoNeutrons,INSTRUMENT.DoNumbers);
list4=list(lab(4),INSTRUMENT.alpha,INSTRUMENT.angles);
list5=list(lab(5),INSTRUMENT.theta,INSTRUMENT.angles);
list6=list(lab(6),1,["no","yes"]);
rep=x_choices('PlotInstrument3D',list(list1,list2,list3,list4,list5,list6));
if not(isempty(rep))
  INSTRUMENT.FirstView=rep(1);
  INSTRUMENT.LastView=rep(2);
  INSTRUMENT.DoNeutrons=rep(3);
  INSTRUMENT.MaxNeutrons=evstr(INSTRUMENT.DoNumbers(INSTRUMENT.DoNeutrons));
  INSTRUMENT.alpha=rep(4);
  INSTRUMENT.theta=rep(5);
  INSTRUMENT.count=0;
  if rep(6)==2
    l=list('Exit Scilab?',1,['yes','no']);
    Stop=x_choices('Exit?',list(l));
    if not(isempty(Stop))
      if Stop(1)==1
        disp('Stopping here!');
  	quit
      end
    end
  end
else
  INSTRUMENT.count=0;
end
// Check if a replot should be done (e.g. MaxNeutrons is 0)
if INSTRUMENT.MaxNeutrons==0
  PlotInstrument3D();
end
endfunction

function circle(plane,x,y,z,r)
// Input circle coordinates
global INSTRUMENT
global component
global coordinates
global listcnt
a=r*cos(2*%pi/24*[0:24]);
b=r*sin(2*%pi/24*[0:24]);
if strsame(plane,'xy')|strsame(plane,'yx')
  x=x+a;
  y=y+b;
  z=z+0*a;
elseif strsame(plane,'zx')|strsame(plane,'xz')
  x=x+a;
  z=z+b;
  y=y+0*a;
elseif strsame(plane,'yz')|strsame(plane,'zy')
  y=y+a;
  z=z+b;
  x=x+0*a;
end
listcnt=listcnt+1;   
coords=[x;y;z;1+0*z];
coordinates(listcnt)=coords;
tmp=['INSTRUMENT.' component '.K=[]'];
execstr(strcat(tmp));
tmp=['INSTRUMENT.' component '.K=coordinates'];
execstr(strcat(tmp)); 
tmp=['INSTRUMENT.' component '.n=listcnt'];
execstr(strcat(tmp));
endfunction

function  dotrace(varargin) 
endfunction

function  endtrace()            
global INSTRUMENT
INSTRUMENT.FirstView=1;
INSTRUMENT.LastView=size(INSTRUMENT.name,2);
// Possibly first and last component names have been given...
if isfield(INSTRUMENT,'firstcomp')
  for j=1:size(INSTRUMENT.name,2)
    if strsame(INSTRUMENT.firstcomp,INSTRUMENT.name(j))
      INSTRUMENT.FirstView=j;
    end
  end
end
if isfield(INSTRUMENT,'lastcomp')
  for j=1:size(INSTRUMENT.name,2)
    if strsame(INSTRUMENT.lastcomp,INSTRUMENT.name(j))
      INSTRUMENT.LastView=j
    end
  end
end
INSTRUMENT.DoNeutrons=1;
INSTRUMENT.MaxNeutrons=0;
INSTRUMENT.DoNumbers=["0","1","10","50","100","500","1000"];
INSTRUMENT.Timeouts=["100","500","1000","2000","5000","10000"];
INSTRUMENT.Traced=0;
INSTRUMENT.angles=string([-180:10:180]);
INSTRUMENT.alpha=19;
INSTRUMENT.theta=10;
// Check if mcdisplay.pl was called with --save parameter:
if INSTRUMENT.save==0
  parmwin()
end
PlotInstrument3D();
if INSTRUMENT.save==1
  xsave(strcat([INSTRUMENT.descr '.scg']));
  INSTRUMENT.save=0;
end
endfunction

function neutron_scatter(varargin)         
endfunction

function neutron_state(xyz)  
global component;
global INSTRUMENT;
global Transform;
global States;
global Neutcount;
xyz=Transform*[xyz(1:3)';1];
States=[States xyz];
if INSTRUMENT.Traced==0
  INSTRUMENT.Neutrons=list();
end
INSTRUMENT.Neutrons(1+INSTRUMENT.Traced)=States;
endfunction

function new_neutron
global INSTRUMENT;
if INSTRUMENT.Traced<INSTRUMENT.MaxNeutrons-1
  INSTRUMENT.Draw=0;
elseif INSTRUMENT.Traced==INSTRUMENT.MaxNeutrons-1
  INSTRUMENT.Draw=1;
end
endfunction

function neutron_leave
// Time to redraw instrument?
global INSTRUMENT
if INSTRUMENT.Draw==1
  PlotInstrument3D();
  INSTRUMENT.Traced=0;
else
  INSTRUMENT.Traced=INSTRUMENT.Traced+1;
end	
endfunction

function  setcomp_trace(name)      
global component;
global INSTRUMENT;
global Transform;
global States;
component=name;
startcomp='guideCurved1';
Transform=evstr(strcat(['INSTRUMENT.',component,'.T;']));
States=[];
endfunction

function trace_component(mycomp)
  global component
  global coordinates
  global listcnt;
  component=mycomp;
  coordinates=list();
  listcnt=0;
endfunction


function PlotInstrument3D()
 global INSTRUMENT;
 clf(0);
  colors=['y','m','c','g','b'];
  // Loop over all component names:
  cidx=0;
  centres=[];
  firstcomp=INSTRUMENT.FirstView;
  lastcomp=INSTRUMENT.LastView;
  alpha=INSTRUMENT.angles(INSTRUMENT.alpha);
  theta=INSTRUMENT.angles(INSTRUMENT.theta);
  view=evstr(strcat(['[' theta ' ' alpha '];']));
  INSTRUMENT.view=view;
  Pcount=0;
  Plist=list();
  for j=1:size(INSTRUMENT.name,2)
    // Should we plot this?
    if j==firstcomp
      firstcomp=[];
    end
    if isempty(firstcomp)
      cidx=cidx+1;
      col=colors(modulo(cidx,size(colors,2))+1)
      component=INSTRUMENT.name(j);
      T=evstr(strcat(['INSTRUMENT.' component '.T;']));
      centres=[centres T(:,4)];
      Lines=evstr(strcat(['INSTRUMENT.' component '.K;']));
      for k=1:length(Lines)
        xyz=T*Lines(k);
        x=xyz(1,:);
        y=xyz(2,:);
        z=xyz(3,:);
 	Pcount=Pcount+1;
        Plist(Pcount)=xyz(3,:);
        Pcount=Pcount+1;
        Plist(Pcount)=xyz(1,:);
        Pcount=Pcount+1;
        Plist(Pcount)=xyz(2,:);
        Pcount=Pcount+1;
        Plist(Pcount)=col;
      end
    end
    if j==lastcomp
      firstcomp=lastcomp;
    end
  end
  plot3(Plist,'axis','equal','view',view,'xlabel','z/[m]','ylabel','x/[m]','zlabel','y/[m]');
  ax=axis();
  xx=ax(3:4);
  yy=ax(5:6);
  zz=ax(1:2);
  INSTRUMENT.axis=ax;
  idx=centres(1,:)>=xx(1) & centres(1,:)<=xx(2) & centres(2,:)>=yy(1) & centres(2,:)<=yy(2) & centres(3,:)>=zz(1) & centres(3,:)<=zz(2)
  c1=centres(1,idx);
  c2=centres(2,idx);
  c3=centres(3,idx);
  centres=[c1;c2;c3];
  hold on
  plot3(centres(3,:),centres(1,:),centres(2,:),'r','view',view,'xlabel','z/[m]','ylabel','x/[m]','zlabel','y/[m]');
  xtitle(INSTRUMENT.descr);
  unsetmenu(gcw(),'Zoom')
  unsetmenu(gcw(),'UnZoom')
  // Check if we are currently doing simple 'replots' - but not if save is 1...
  if (INSTRUMENT.MaxNeutrons==0 & INSTRUMENT.save==0)
    parmwin();
  end

endfunction

function PlotNeutron(x,y,z)
global INSTRUMENT
INSTRUMENT.count=INSTRUMENT.count+1;
plot3(x,y,z,'k-','view',INSTRUMENT.view,'axis',INSTRUMENT.axis,'xlabel','z/[m]','ylabel','x/[m]','zlabel','y/[m]');
if INSTRUMENT.count==INSTRUMENT.MaxNeutrons
  parmwin();
  PlotInstrument3D();
end
endfunction




