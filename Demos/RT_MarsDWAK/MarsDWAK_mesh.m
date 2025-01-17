% build up an earth model
clear all; clc;
addpath('../../modelbuilder/');  

fmesh  = 'output/RTMDWAK8k/RTMDWAK_3L_8k';
tetgen = '../../packages/tetgen1.5.0/tetgen'; 

% finite element order (choose 1 or 2)
pOrder  = 1;

% set the value to control the degrees of freedom
a = 1.2e8; % 3k7 8k
%a = 9e9; % 3k7 20k
%a = 4e9; % 6k 40k
%a = 3e7; % 10k 80k
%a = 6e6; % 15k 120k
%a = 3.8e6; % 15k 150k
%a = 6e6; % 23k 200k
%a = 7.75e5; % 42k 500k
%a = 3.7e5; % 42k 1M
%a = 1.65e5; % 94k 2M

%a = 5.8e5; % 167k 4M
%a = 3.1e5; % 377k 8M
%a = 1.5e5; % 589k 16M
%a = 7.5e4; % 1047k 32M
%a = 3.6e4; % 1507k 64M
%a = 1.75e4; % 2353k 128M
%a = 8.0e3; % 3077k 256M
%a = 5.0e3; % 3077k 400M
%a = 4.0e3; % 3077k 512M
%a = 3.0e3; % 3077k 690M


tic
% load radial information
load ../../radialmodels/ellmars/marsDWAK_3L_ellp_edit.mat

% radius 
R1 = RD(3,1); R2 = RD(2,1); 

% load surface mesh
load ../../discontinuities/MarsCrust/workdata/Msurf_3716.mat
p1 = p;
np1 = size(p1,1); t1 = t; nt1 = size(t1,1);

% load crust-mantle interface, solid-solid interface
load ../../discontinuities/MarsCrust/workdata/Mcmi_440.mat
p2 = p; 
np2 = size(p2,1); t2 = t + np1; nt2 = size(t2,1);

% load core-mantle interface, fluid-solid interface
load ../../discontinuities/MarsEllp/MCMB419/MarsEllp260.mat
p3 = p*R2/nthroot(1-419e-5,3); % change it!!
np3 = size(p3,1); t3 = t + np1 + np2;  nt3 = size(t3,1);

istart = 1; iend = np1; 
pin(istart:iend,:) = p1;
istart = iend + 1; iend = iend + np2; 
pin(istart:iend,:) = p2;
istart = iend + 1; iend = iend + np3; 
pin(istart:iend,:) = p3;

istart = 1; iend = nt1; 
tin(istart:iend,:) = t1;
istart = iend + 1; iend = iend + nt2; 
tin(istart:iend,:) = t2;
istart = iend + 1; iend = iend + nt3; 
tin(istart:iend,:) = t3;

% generate internal surfaces 
trisurf2poly(fmesh,pin,tin);
toc 

fhed = [fmesh,'.1_mesh.header'];
fele = [fmesh,'.1_ele.dat'];
fngh = [fmesh,'.1_neigh.dat'];
fnde = [fmesh,'.1_node.dat'];

% generate the mesh
unix([tetgen,' -pq1.5nYVFAa',num2str(a,'%f'),' ',fmesh,'.poly']);
toc
[pout,tout,~,at,neigh] = read_mesh3d([fmesh,'.1']);

dh =[size(tout,1) size(pout,1)];
fid = fopen(fhed,'w');
fprintf(fid,'%d %d',dh);

fid=fopen(fele,'w');
fwrite(fid,tout','int');
fid=fopen(fngh,'w');
fwrite(fid,neigh','int');
fid=fopen(fnde,'w');
fwrite(fid,pout','float64');

%vtk_write_general([fmesh,'_face.vtk'],'test',pin,tin);
size(tout)
toc


run MarsDWAK_models
