matlabrc; clc; close all;
addpath(genpath('../lib'))

my_mesh = Mesh('../../data/models/suzanne.obj');

my_mesh.vertex_values = my_mesh.vertex_normals(:,3);
my_mesh.plot();
my_mesh.plot_face_normals();