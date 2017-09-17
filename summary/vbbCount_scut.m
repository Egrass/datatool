% ͳ��txt��ע�ļ�����Ϣ
function [allCount,allbboxList,vCount,vbboxList,lCount] = vbbCount_scut(pth)
close all;
clear;
clc;

[~,setIds,vidIds] = dbInfo('scut');
% pth = 'F:\DataSet\SCUT_FIR_101\datasets\';
% txtNameList = dir([path '*.txt']);                                         % ��ȡ annotations �ļ��е����� txt �ļ�
load([pth 'road.mat']);                                                   % load road sence info
% l = {txtNameList.name};
% l = cell2mat(l');
% l = l(:,1:end-4);
% l = mat2cell(l,ones(size(l,1),1),size(l,2));
% road = [road,l];
% % ��Ƶ����
% vbbNum = numel(txtNameList);
vbbNum = numel([vidIds{:}]);
% ��һ��Ƶͳ����Ϣ
vhead = {'road','fname','nFrame','lFrame','bbox','uobjs','occl',...
         'frame_per_obj','bbox_per_frame'};
vCount=cell(vbbNum,numel(vhead)-1);

% ÿ��bbox����Ϣ
bhead = {'filename','frame','id','label','pos_x','pos_y','pos_w','pos_h',...
         'center_x','center_y','occl','ratio','posv_x','posv_y','posv_w',...
         'posv_h'};
allbboxList = {};

% ÿ����Ƶbbox����Ϣ
vbhead = {'road','fName','bboxList'};
vbboxList=cell(vbbNum,numel(vbhead)-1);

% ÿ������ͳ����Ϣ
lhead = {'fname','label','nFrame','lFrame','bbox','uobjs','occl',...
         'bbox_per_obj','bbox_per_frame'};
lCount=cell(vbbNum*6,numel(lhead));
i = 1;
for s=1:length(setIds)
    ticId = ticStatus(['Extract set' num2str(setIds(s)) ':'],0.2,1);
  for v=1:length(vidIds{s})
    % load ground truth
    name=sprintf('set%02d/V%03d',setIds(s),vidIds{s}(v));
    A=vbb('vbbLoadTxt',[pth '/annotations/' name]);
      
% for i = 1:length(txtNameList)
%     fNameTxt = [path, txtNameList(i).name];                                % ԭʼ�� txt �ļ����ڵ�·��+����
%     A = vbb('vbbLoadTxt', fNameTxt);                                       % ����txt�ļ�
    
    % ��Ƶͳ�Ʋ���
    
    objFrames = A.objEnd - A.objStr + 1;                                   % Ŀ�����֡��    
    bboxNum = sum(objFrames);
    bboxList = cell(bboxNum,8);                                            % frame,id,label,pos,posv,occl,ratio,center
    frames_bNum = zeros(1,A.nFrame);                                       % ÿ֡bbox��
    n = 1;
    for j = 1:A.nFrame
       frames_bNum(j) = numel(A.objLists{j});
       for k = 1:frames_bNum(j)
           obj = A.objLists{j}(k);
           bboxList(n,:) = {j,obj.id, A.objLbl(obj.id), obj.pos,...
                    obj.posv, obj.occl, obj.pos(3)/obj.pos(4), ...
                    [obj.pos(1)+obj.pos(3)/2, obj.pos(2)+obj.pos(4)/2]};
           n = n + 1;
       end
    end
    
    % ��bboxList�е�cellչ��������ͳ��
    % չ�����bboxList����bhead�е���Ϣ
%     fName = txtNameList(i).name(1:end-4);
    fName = name;
    cfName = repmat(fName,bboxNum,1);
    cfName = mat2cell(cfName,ones(bboxNum,1),size(cfName,2));
    frame = bboxList(:,1);
    id    = bboxList(:,2);
    label = bboxList(:,3);
    pos   = bboxList(:,4);
    pos   = cell2mat(pos);
    pos   = mat2cell(pos,ones(bboxNum,1),ones(4,1));
    posv  = bboxList(:,5);
    posv  = cell2mat(posv);
    posv  = mat2cell(posv,ones(bboxNum,1),ones(4,1));
    occl  = bboxList(:,6);
    ratio = bboxList(:,7);
    center= bboxList(:,8);
    center= cell2mat(center);
    center= mat2cell(center,ones(bboxNum,1),ones(2,1));
    xbboxList = [cfName,frame,id,label,pos,center,occl,ratio,posv];
    
    % ÿ����Ƶ��Ϣͳ��
    A.fileName = fName;                                                    % ����ļ���
    A.objFrames = objFrames;
    A.bboxNum = bboxNum;
    A.bboxList = cell2struct(xbboxList',bhead);
    A.frames_bNum = frames_bNum;                                           % ÿ֡bbox��
    A.lFrame = sum(frames_bNum ~=0);                                       % ���֡��
    A.uobjs = sum(A.objInit);                                              % Ŀ����
    A.occlNum = sum(cell2mat(bboxList(:,6)));                              % ���ڵ�Ŀ����
    A.bbox_per_obj = A.bboxNum/A.uobjs;                                         
    A.bbox_per_frame = A.bboxNum/A.nFrame;
    % ÿ����Ƶ�洢ͳ����Ϣ��vCount
    tallCount= {fName,A.nFrame,A.lFrame,A.bboxNum,A.uobjs,A.occlNum,...
        A.bbox_per_obj,A.bbox_per_frame};
    vCount(i,:) = tallCount;
 
    % ͳ��i��Ƶ��ÿ����ǩ����ͳ����Ϣ
    A.walk_person = label_count(A,'walk_person');                 % ����ͳ��
    A.ride_person = label_count(A,'ride_person');                 % �ﳵ��ͳ��
    A.people      = label_count(A,'people');                      % ��Ⱥͳ��
    A.person_m    = label_count(A,'person?');                     % ��������
    A.people_m    = label_count(A,'people?');                     % ��������
    A.squat_person= label_count(A,'squat_person');                % ��������
    
    if(1)
        validLabel(A);
    end
    
    % ���ṹ��չ����cell������ӱ�ǩ��Ϣ
    walk_person   = label2cell(A.walk_person,'walk_person');
    ride_person   = label2cell(A.ride_person,'ride_person');
    people        = label2cell(A.people,'people');
    person_m      = label2cell(A.person_m,'person?');
    people_m      = label2cell(A.people_m,'people?');
    squat_person  = label2cell(A.squat_person,'squat_person');
    
    % �����Ƶ�ļ���
    walk_person   = [A.fileName,walk_person];    
    ride_person   = [A.fileName,ride_person];    
    people        = [A.fileName,people];    
    person_m      = [A.fileName,person_m];    
    people_m      = [A.fileName,people_m];
    squat_person  = [A.fileName,squat_person];
    
    % ÿ����Ƶÿ����ǩ���ͳ����Ϣ�洢��lCount��
    lCount((i-1)*6+1:i*6,:) = [walk_person;
                               ride_person;
                               people;
                               person_m;
                               people_m;
                               squat_person];
    
    % ��ÿ����Ƶ��bboxList�洢����
    tvCount={fName,A.bboxList};
    vbboxList(i,:) = tvCount;
    
    % ÿ����Ƶ��bboxList���ӵ�ȫ���ݼ���bboxList��
    allbboxList = [allbboxList;xbboxList];
    i = i+1;
  end
end
% ��cellת��Ϊstruct����鿴
lCount = cell2struct(lCount',lhead);
vbboxList = [road,vbboxList];
vbboxList = cell2struct(vbboxList',vbhead);
vCount = [road,vCount];
vCount = cell2struct(vCount',vhead);
allbboxList = cell2struct(allbboxList',bhead);

% ����ͳ����Ϣ
allhead = {'Type','nFrame','lFrame','bbox','uobjs','occl','frame_per_obj','bbox_per_frame'};
allCount = cell(7,numel(allhead));

% �������ݼ�����������ͳ����Ϣ
all             = all_count(vCount);
all_walk_person = all_label_count(lCount,'walk_person');
all_ride_person = all_label_count(lCount,'ride_person');
all_people      = all_label_count(lCount,'people');
all_person_m    = all_label_count(lCount,'person?');
all_people_m    = all_label_count(lCount,'people?');
all_squat_person= all_label_count(lCount,'squat_person');

% �洢��allCount
allCount(1,:) = label2cell(all,'all');
allCount(2,:) = label2cell(all_walk_person,'walk_person');
allCount(3,:) = label2cell(all_ride_person,'ride_person');
allCount(4,:) = label2cell(all_people,'people');
allCount(5,:) = label2cell(all_person_m,'person?');
allCount(6,:) = label2cell(all_people_m,'people?');
allCount(7,:) = label2cell(all_squat_person,'squat_person');
allCount = cell2struct(allCount',allhead);

% ͳ�ƿ�ȷֲ�

% ͳ�ƿ�߱ȷֲ�

% ͳ��λ�÷ֲ�

end

function alltype = all_count(vCount)
    alltype.nFrame = sum([vCount.nFrame]);
    alltype.lFrame = sum([vCount.lFrame]);
    alltype.bbox   = sum([vCount.bbox]);
    alltype.uobjs  = sum([vCount.uobjs]);
    alltype.occl   = sum([vCount.occl]);
    alltype.bbox_per_frame = 0;
    alltype.bbox_per_obj = 0;
    if alltype.lFrame ~= 0
        alltype.bbox_per_frame = alltype.bbox/alltype.nFrame;
    end
    if alltype.uobjs ~= 0
        alltype.bbox_per_obj = alltype.bbox/alltype.uobjs; 
    end
end

function type = all_label_count(lCount,label)
    index       = strcmp([{lCount.label}],label);
    type.nFrame = sum([lCount(index).nFrame]);
    type.lFrame = sum([lCount(index).lFrame]);
    type.bbox   = sum([lCount(index).bbox]);
    type.uobjs  = sum([lCount(index).uobjs]);
    type.occl   = sum([lCount(index).occl]);
    type.bbox_per_frame = 0;
    type.bbox_per_obj = 0;
    if type.lFrame ~= 0
        type.bbox_per_frame = type.bbox/type.nFrame;
    end
    if type.uobjs ~= 0
        type.bbox_per_obj = type.bbox/type.uobjs; 
    end
end

function clabel = label2cell(obj,label)
% ������ǩ��ͳ�Ʋ����ṹ�壬ת��Ϊcell���ڴ洢
    clabel = {label,obj.nFrame,obj.lFrame,obj.bbox,obj.uobjs,obj.occl,...
    obj.bbox_per_obj,obj.bbox_per_frame};
end

function flag = validLabel(A)
% ��֤��ע�ļ��б�ǩ�Ƿ��д���
    flag = strcmp(A.objLbl,'walk_person');
    flag = flag | strcmp(A.objLbl,'ride_person');
    flag = flag | strcmp(A.objLbl,'people');
    flag = flag | strcmp(A.objLbl,'person?');
    flag = flag | strcmp(A.objLbl,'people?');
    flag = flag | strcmp(A.objLbl,'squat_person');    
    disp(['filename:' A.fileName ' error:' num2str(find(~flag))]);
end

function [obj] = label_count(A,label)
% ͳ�����label����Ϣ
    bboxList    = A.bboxList;
    index       = strcmp([bboxList.label],label);
    obj.nFrame  = A.nFrame;
    frame       = [bboxList(index).frame];
    obj.lFrame  = length(unique(frame));
    obj.bbox    = length(frame);
    id          = [bboxList(index).id];
    obj.uobjs   = length(unique(id));
    obj.occl    = sum([bboxList(index).occl]);
    obj.bbox_per_frame = 0;
    obj.bbox_per_obj = 0;
    if obj.lFrame ~= 0
        obj.bbox_per_frame = obj.bbox/obj.nFrame;
    end
    if obj.uobjs ~= 0
        obj.bbox_per_obj = obj.bbox/obj.uobjs; 
    end      
end