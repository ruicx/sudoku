%% 重复代码
for aa = 1:81
    fprintf('function pushbutton%d_Callback(hObject, eventdata, handles)\n\n', aa)
    fprintf('%% 选中坐标\n')
    fprintf('handles.selectLoc = %d;\n\n', aa)
    fprintf('%% Update handles structure\n')
    fprintf('guidata(hObject, handles);\n\n\n')
end