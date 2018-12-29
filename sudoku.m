function varargout = sudoku(varargin)
% SUDOKU MATLAB code for sudoku.fig
%      SUDOKU, by itself, creates a new SUDOKU or raises the existing
%      singleton*.
%
%      H = SUDOKU returns the handle to a new SUDOKU or the handle to
%      the existing singleton*.
%
%      SUDOKU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUDOKU.M with the given input arguments.
%
%      SUDOKU('Property','Value',...) creates a new SUDOKU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sudoku_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sudoku_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sudoku

% Last Modified by GUIDE v2.5 29-Oct-2017 21:30:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sudoku_OpeningFcn, ...
                   'gui_OutputFcn',  @sudoku_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before sudoku is made visible.
function sudoku_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sudoku (see VARARGIN)

% 定时器初始化
handles.ht = timer;                                     % 定义定时器
set(handles.ht, 'ExecutionMode', 'FixedRate');          % ExecutionMode   执行的模式
set(handles.ht, 'Period', 1);                           % 周期
set(handles.ht, 'TimerFcn', {@dispTime, handles});      % 定时器执行函数
start(handles.ht);                                      % 启动定时器

% 位置初始化
handles.selectLoc = 0;

% 填充计数器初始化
handles.fillNum = 0;

% 留空的数量
handles.dragNum = 20;

% 地图初始化
[gameMap, showMap] = genSudoku(handles.dragNum);
handles.gameMap = gameMap;
handles.showMap = showMap;

% 初始化显示
for aa = 1:81
    if showMap(aa) ~= 0
        eval(sprintf('set(handles.pushbutton%d, ''String'', ''%d'')', aa, showMap(aa)))
        eval(sprintf('set(handles.pushbutton%d, ''Enable'', ''inactive'')', aa))
        eval(sprintf('set(handles.pushbutton%d, ''ForegroundColor'', [0 0 0])', aa))
    else
        eval(sprintf('set(handles.pushbutton%d, ''String'', '''')', aa))
        eval(sprintf('set(handles.pushbutton%d, ''Enable'', ''on'')', aa))
        eval(sprintf('set(handles.pushbutton%d, ''ForegroundColor'', [0 0 1])', aa))
    end
end

% Choose default command line output for sudoku
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sudoku wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% 定时器的执行函数 
function dispTime(hObject, eventdata, handles)

set(handles.text3, 'string', datestr(now))


% --- Outputs from this function are returned to the command line.
function varargout = sudoku_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% 生成数独矩阵
function [gameMap, showMap] = genSudoku(dragNum)

gameMap = zeros(9);
gameMap(:,1) = randperm(9)';

mapInfo = cell(81, 1);

aa = 10;
debugCount = 0;

while aa <= 81

    debugCount = debugCount + 1;
    
    % 索引错误进入调试
    if aa < 10
        keyboard
    end

    if isempty(mapInfo{aa})

        % 初次到达, 获取节点信息
        temp = possibleNum(gameMap, aa);
        mapInfo{aa} = temp;

    else

        % 回溯到达, 剪枝
        temp = mapInfo{aa};
        temp = temp(temp ~= gameMap(aa));
        mapInfo{aa} = temp;

    end

    if isempty(temp)

        % 节点无法填充, 回溯
        gameMap(aa) = 0;
        aa = aa - 1;

    else

        % 节点可以填充, 填充并前进
        gameMap(aa) = temp(1);
        aa = aa + 1;

    end

end

dragLoc = randperm(81, dragNum);
showMap = gameMap;
showMap(dragLoc) = 0;



% 检查是否符合数独要求
function isUnique = checkUnique(gameMap, ind)

[x, y] = ind2sub([9, 9], ind);
isUnique = true;

% 检查行
ChosenRow = gameMap(x,gameMap(x,:)>0);
if length(unique(ChosenRow)) < length(ChosenRow)
    isUnique = false;
end

% 检查列
ChosenCol = gameMap(gameMap(:,y)>0,y);
if length(unique(ChosenCol)) < length(ChosenCol)
    isUnique = false;
end

% 检查区域
areaX = 3 * floor(x/3.01) + (1:3);
areaY = 3 * floor(y/3.01) + (1:3);
ChosenArea = reshape(gameMap(areaX, areaY), 1, []);
ChosenArea = ChosenArea(ChosenArea>0);
if length(unique(ChosenArea)) < length(ChosenArea)
    isUnique = false;
end


% 每个位置允许填写的数字
function rsl = possibleNum(gameMap, ind)

[x, y] = ind2sub([9, 9], ind);
areaX = 3 * floor(x/3.01) + (1:3);
areaY = 3 * floor(y/3.01) + (1:3);

ChosenRow = gameMap(x,:);
ChosenCol = gameMap(:,y);
ChosenArea = reshape(gameMap(areaX, areaY), 1, []);

used = unique([ChosenRow, ChosenCol', ChosenArea]);
rsl = setdiff(1:9, used);


% --- Executes on button press in pushbuttonSent.
function pushbuttonSent_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 未选择, 不做响应
if handles.selectLoc == 0
    return
end

% 获取输入
NumIn = str2num(get(handles.edit1, 'String'));
loc = handles.selectLoc;

% 输入不在1-9之间, 不做响应
if isempty(NumIn) || NumIn > 9 || NumIn < 1
    return
end

% 显示
eval(sprintf('set(handles.pushbutton%d, ''String'', ''%d'')', loc, NumIn))

% 增加填充计数器
if handles.showMap(loc) == 0
    handles.fillNum = handles.fillNum + 1;
end

% 记录填充数字
handles.showMap(loc) = NumIn;

% 如果所有位置被填充, 结束游戏
if handles.fillNum == handles.dragNum
    
    % 检查填充是否正确
    isRight = true;
    for aa = 1:81
        if ~checkUnique(handles.showMap, aa)
            isRight = false;
            break
        end
    end
    
    if isRight
        hlt = msgbox('');
        texth = findall(hlt, 'Type', 'Text');
        set(texth, 'FontSize', 16, 'HorizontalAlignment', 'center', 'String', '真慢╮(╯▽╰)╭')
        set(texth, 'Position', [62.5 26 125])
        pushbuttonh =  findall(hlt, 'Style', 'pushbutton');
        set(pushbuttonh, 'Callback', {@pushbuttonMsgClose_Callback, handles, hlt})
    else
        hlt = msgbox('');
        texth = findall(hlt, 'Type', 'Text');
        set(texth, 'FontSize', 16, 'HorizontalAlignment', 'center', 'String', '真菜')
        set(texth, 'Position', [62.5 26 125])
        pushbuttonh =  findall(hlt, 'Style', 'pushbutton');
        set(pushbuttonh, 'Callback', {@pushbuttonMsgClose_Callback, handles, hlt})
    end
    
end


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbuttonRestart.
function pushbuttonRestart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRestart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 位置初始化
handles.selectLoc = 0;

% 填充计数器初始化
handles.fillNum = 0;

% 获取留空数量输入
NumIn = str2num(get(handles.edit2, 'String'));

% 输入不在0-81之间, 提示错误
if isempty(NumIn) || NumIn > 81 || NumIn < 0
    'pass';
else
    handles.dragNum = NumIn;
end


% 地图初始化
[gameMap, showMap] = genSudoku(handles.dragNum);
handles.gameMap = gameMap;
handles.showMap = showMap;

% 初始化显示
for aa = 1:81
    if showMap(aa) ~= 0
        eval(sprintf('set(handles.pushbutton%d, ''String'', ''%d'')', aa, showMap(aa)))
        eval(sprintf('set(handles.pushbutton%d, ''Enable'', ''inactive'')', aa))
        eval(sprintf('set(handles.pushbutton%d, ''ForegroundColor'', [0 0 0])', aa))
    else
        eval(sprintf('set(handles.pushbutton%d, ''String'', '''')', aa))
        eval(sprintf('set(handles.pushbutton%d, ''Enable'', ''on'')', aa))
        eval(sprintf('set(handles.pushbutton%d, ''ForegroundColor'', [0 0 1])', aa))
    end
end

% Choose default command line output for sudoku
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbuttonMsgClose.
function pushbuttonMsgClose_Callback(hObject, eventdata, handles, hlt)

% 重置游戏
pushbuttonRestart_Callback(handles.pushbuttonRestart, eventdata, handles)

% 关闭消息窗口
close(hlt)






function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








function pushbutton1_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 1;

% Update handles structure
guidata(hObject, handles);


function pushbutton2_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 2;

% Update handles structure
guidata(hObject, handles);


function pushbutton3_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 3;

% Update handles structure
guidata(hObject, handles);


function pushbutton4_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 4;

% Update handles structure
guidata(hObject, handles);


function pushbutton5_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 5;

% Update handles structure
guidata(hObject, handles);


function pushbutton6_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 6;

% Update handles structure
guidata(hObject, handles);


function pushbutton7_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 7;

% Update handles structure
guidata(hObject, handles);


function pushbutton8_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 8;

% Update handles structure
guidata(hObject, handles);


function pushbutton9_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 9;

% Update handles structure
guidata(hObject, handles);


function pushbutton10_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 10;

% Update handles structure
guidata(hObject, handles);


function pushbutton11_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 11;

% Update handles structure
guidata(hObject, handles);


function pushbutton12_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 12;

% Update handles structure
guidata(hObject, handles);


function pushbutton13_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 13;

% Update handles structure
guidata(hObject, handles);


function pushbutton14_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 14;

% Update handles structure
guidata(hObject, handles);


function pushbutton15_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 15;

% Update handles structure
guidata(hObject, handles);


function pushbutton16_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 16;

% Update handles structure
guidata(hObject, handles);


function pushbutton17_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 17;

% Update handles structure
guidata(hObject, handles);


function pushbutton18_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 18;

% Update handles structure
guidata(hObject, handles);


function pushbutton19_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 19;

% Update handles structure
guidata(hObject, handles);


function pushbutton20_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 20;

% Update handles structure
guidata(hObject, handles);


function pushbutton21_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 21;

% Update handles structure
guidata(hObject, handles);


function pushbutton22_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 22;

% Update handles structure
guidata(hObject, handles);


function pushbutton23_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 23;

% Update handles structure
guidata(hObject, handles);


function pushbutton24_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 24;

% Update handles structure
guidata(hObject, handles);


function pushbutton25_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 25;

% Update handles structure
guidata(hObject, handles);


function pushbutton26_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 26;

% Update handles structure
guidata(hObject, handles);


function pushbutton27_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 27;

% Update handles structure
guidata(hObject, handles);


function pushbutton28_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 28;

% Update handles structure
guidata(hObject, handles);


function pushbutton29_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 29;

% Update handles structure
guidata(hObject, handles);


function pushbutton30_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 30;

% Update handles structure
guidata(hObject, handles);


function pushbutton31_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 31;

% Update handles structure
guidata(hObject, handles);


function pushbutton32_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 32;

% Update handles structure
guidata(hObject, handles);


function pushbutton33_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 33;

% Update handles structure
guidata(hObject, handles);


function pushbutton34_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 34;

% Update handles structure
guidata(hObject, handles);


function pushbutton35_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 35;

% Update handles structure
guidata(hObject, handles);


function pushbutton36_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 36;

% Update handles structure
guidata(hObject, handles);


function pushbutton37_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 37;

% Update handles structure
guidata(hObject, handles);


function pushbutton38_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 38;

% Update handles structure
guidata(hObject, handles);


function pushbutton39_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 39;

% Update handles structure
guidata(hObject, handles);


function pushbutton40_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 40;

% Update handles structure
guidata(hObject, handles);


function pushbutton41_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 41;

% Update handles structure
guidata(hObject, handles);


function pushbutton42_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 42;

% Update handles structure
guidata(hObject, handles);


function pushbutton43_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 43;

% Update handles structure
guidata(hObject, handles);


function pushbutton44_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 44;

% Update handles structure
guidata(hObject, handles);


function pushbutton45_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 45;

% Update handles structure
guidata(hObject, handles);


function pushbutton46_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 46;

% Update handles structure
guidata(hObject, handles);


function pushbutton47_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 47;

% Update handles structure
guidata(hObject, handles);


function pushbutton48_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 48;

% Update handles structure
guidata(hObject, handles);


function pushbutton49_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 49;

% Update handles structure
guidata(hObject, handles);


function pushbutton50_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 50;

% Update handles structure
guidata(hObject, handles);


function pushbutton51_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 51;

% Update handles structure
guidata(hObject, handles);


function pushbutton52_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 52;

% Update handles structure
guidata(hObject, handles);


function pushbutton53_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 53;

% Update handles structure
guidata(hObject, handles);


function pushbutton54_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 54;

% Update handles structure
guidata(hObject, handles);


function pushbutton55_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 55;

% Update handles structure
guidata(hObject, handles);


function pushbutton56_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 56;

% Update handles structure
guidata(hObject, handles);


function pushbutton57_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 57;

% Update handles structure
guidata(hObject, handles);


function pushbutton58_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 58;

% Update handles structure
guidata(hObject, handles);


function pushbutton59_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 59;

% Update handles structure
guidata(hObject, handles);


function pushbutton60_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 60;

% Update handles structure
guidata(hObject, handles);


function pushbutton61_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 61;

% Update handles structure
guidata(hObject, handles);


function pushbutton62_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 62;

% Update handles structure
guidata(hObject, handles);


function pushbutton63_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 63;

% Update handles structure
guidata(hObject, handles);


function pushbutton64_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 64;

% Update handles structure
guidata(hObject, handles);


function pushbutton65_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 65;

% Update handles structure
guidata(hObject, handles);


function pushbutton66_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 66;

% Update handles structure
guidata(hObject, handles);


function pushbutton67_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 67;

% Update handles structure
guidata(hObject, handles);


function pushbutton68_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 68;

% Update handles structure
guidata(hObject, handles);


function pushbutton69_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 69;

% Update handles structure
guidata(hObject, handles);


function pushbutton70_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 70;

% Update handles structure
guidata(hObject, handles);


function pushbutton71_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 71;

% Update handles structure
guidata(hObject, handles);


function pushbutton72_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 72;

% Update handles structure
guidata(hObject, handles);


function pushbutton73_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 73;

% Update handles structure
guidata(hObject, handles);


function pushbutton74_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 74;

% Update handles structure
guidata(hObject, handles);


function pushbutton75_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 75;

% Update handles structure
guidata(hObject, handles);


function pushbutton76_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 76;

% Update handles structure
guidata(hObject, handles);


function pushbutton77_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 77;

% Update handles structure
guidata(hObject, handles);


function pushbutton78_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 78;

% Update handles structure
guidata(hObject, handles);


function pushbutton79_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 79;

% Update handles structure
guidata(hObject, handles);


function pushbutton80_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 80;

% Update handles structure
guidata(hObject, handles);


function pushbutton81_Callback(hObject, eventdata, handles)

% 选中坐标
handles.selectLoc = 81;

% Update handles structure
guidata(hObject, handles);



