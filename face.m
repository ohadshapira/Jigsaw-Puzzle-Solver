classdef face < matlab.mixin.Copyable
    
    properties
        type        % 'hole' , 'head' or 'flat'
        harris_features % features extracted from edges of face
        distance_from_corners_line %distance in pixels from corners line to face end
        face_length % distance in pixels from both corners of face
        ratio % face_length\distance_from_corners_line
        color_strip     % strip of colored pixels from the edge, ordered clockwise.
        face_points     % vector of  x-y locations for each edge point from 
                        % one corner to second ordered clockwise
    end
    methods
        function obj=face(input_representation,input_type,distance_from_corners_line,face_length)  % class constractor
            valid_types={'head','hole','flat'};
            if ~ismember(input_type,valid_types)    % check if type is valid
                throwAsCaller(MException('','Type must be one of the following: head,hole or flat'))
            else
                obj.type = input_type;
                obj.harris_features = input_representation;
                obj.distance_from_corners_line = distance_from_corners_line;
                obj.face_length = face_length;
                
                if(distance_from_corners_line ~= 0)
                    obj.ratio = face_length / distance_from_corners_line;
                else
                    obj.ratio = 0;
                end
                
            end
        end
        
        function rotate_face(obj,image_size)
            
            if isempty(obj.face_points)~=1
                temp=obj.face_points(:,2);
                obj.face_points(:,2)=image_size(2)-obj.face_points(:,1)+1;
                obj.face_points(:,1)=temp;
            end
        end
        
    end
    methods (Static)
        
    end
    
end
        