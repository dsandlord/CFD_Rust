classdef Mesh
    properties
        % Geometry properties:
        vertices
        vertex_normals
        faces
        face_normals
        face_centers
        
        % Subdivision data:
        subdivided_vertices
        subdivided_faces
        subdivided_vertex_normals
        subdivided_face_normals
        subdivided_face_centers
        
        % FEA properties:
        vertex_values
    end
    
    methods (Access = public)
        function [self] = Mesh(path,file_type)
            % Set the default input file type:
            if nargin == 1
                file_type = 'obj';
            end
            file_type = lower(file_type);
            
            % Load the file:
            if strcmp(file_type,'obj')
                % Pre-process to get the number of vertices:
                file_str = fileread(path);
                max_num_vertices = count(file_str,'v ');
                max_num_faces = count(file_str,'f ');
                num_vn_tmp = count(file_str,'vn ');
                
                self.vertices = zeros(max_num_vertices,3);
                self.vertex_normals = zeros(max_num_vertices,3);
                self.faces = zeros(max_num_faces,3);
                
                fvn_tmp = zeros(max_num_faces,3);
                vn_tmp = zeros(num_vn_tmp,3);
                
                v_idx  = 1;
                vn_idx = 1;
                f_idx  = 1;
                
                fid = fopen(path);
                tline = fgetl(fid);
                while ischar(tline)                    
                    file_line = sscanf(tline,'%s',1);
                    switch file_line
                        case 'v'   % vertex
                            self.vertices(v_idx,:) = sscanf(tline(2:end),'%f')';
                            v_idx = v_idx+1;
                            
                        case 'vn'  % vertex normal
                            vn_tmp(vn_idx,:) = sscanf(tline(3:end),'%f')';
                            vn_idx = vn_idx+1;
                            
                        case 'f'   % face
                            str = textscan(tline(2:end),'%s');
                            str = str{1};
                            num_sides = length(str);
                            
                            % Extract definitions:
                            f_tmp  = zeros(num_sides,1);
                            fn_tmp = zeros(num_sides,1);
                            for ii = 1:num_sides
                                vals_cell = strsplit(str{ii},'/','CollapseDelimiters',false);
                                f_tmp(ii)  = str2double(vals_cell{1});
                                fn_tmp(ii) = str2double(vals_cell{3});
                            end
                            
                            % Triangulate if needed:
                            for ii = 1:(num_sides-2)
                                self.faces(f_idx,:) = [f_tmp(1), f_tmp(2+(ii-1)), f_tmp(3+(ii-1))];
                                fvn_tmp(f_idx,:) = [fn_tmp(1), fn_tmp(2+(ii-1)), fn_tmp(3+(ii-1))];
                                f_idx = f_idx+1;
                            end
                    end
                    
                    % Get the next line:
                    tline = fgetl(fid);
                end
                fclose(fid);
                
                % Store the vertex normals individually:
                for ii = 1:size(self.faces,1)
                    for jj = 1:3
                        self.vertex_normals(self.faces(ii,jj),:) = vn_tmp(fvn_tmp(ii,jj),:);
                    end
                end
                
                % Calculate face centers and normals:
                for ii = 1:size(self.faces,1)
                    vert0 = self.vertices(self.faces(ii,1),:);
                    vert1 = self.vertices(self.faces(ii,2),:);
                    vert2 = self.vertices(self.faces(ii,3),:);
                    
                    edge1 = vert1 - vert0;
                    edge2 = vert2 - vert0;
                    
                    self.face_centers(ii,:) = mean([vert0; vert1; vert2]);
                    self.face_normals(ii,:) = normc(cross(edge1,edge2)');
                end

                % Calculate vertex normals if not provided:

            else
                error('%s is not a supported geometry file type.',upper(file_type))
            end                    
            
            % Initialize the vertex values:
            self.vertex_values = zeros(size(self.vertices,1),1);
        end
    end
    
    % Meshing methods:
    methods (Access = public)
        function [] = structured_mesh(self,resolutions)
            assert(numel(resolutions) == 3, 'Must specify resolution for each dimension (xyz)')
            xmax = max(self.vertices(:,1));
            xmin = min(self.vertices(:,1));
            ymax = max(self.vertices(:,2));
            ymin = min(self.vertices(:,2));
            zmax = max(self.vertices(:,3));
            zmin = min(self.vertices(:,3));
            [X,Y,Z] = meshgrid(linspace(xmin,xmax,resolutions(1)),...
                               linspace(ymin,ymax,resolutions(2)),...
                               linspace(zmin,zmax,resolutions(3)));
           plot3(X(:),Y(:),Z(:),'.k');
        end
    end
    
    % FEA Methods:
    
    % Drawing methods:
    methods (Access = public)
        function [] = plot(self,varargin)
            patch('Faces',self.faces,'Vertices',self.vertices,...
                  'FaceVertexCData',self.vertex_values,'FaceColor','interp',...
                  varargin{:}); hold on
            axis equal;
            xlim([-inf inf])
            ylim([-inf inf])
            zlim([-inf inf])
            grid on;
            colorbar;
            rotate3d on;
            colormap(turbo);
        end
        
        function [] = plot_normals(self,varargin)
            quiver3(self.vertices(:,1),self.vertices(:,2),self.vertices(:,3),...
                   self.vertex_normals(:,1),self.vertex_normals(:,2),self.vertex_normals(:,3),...
                   varargin{:}); hold on
        end
        
        function [] = plot_face_normals(self,varargin)
            quiver3(self.face_centers(:,1),self.face_centers(:,2),self.face_centers(:,3),...
                    self.face_normals(:,1),self.face_normals(:,2),self.face_normals(:,3),...
                    varargin{:}); hold on
        end
    end
end