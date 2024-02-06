clc;clear;
fileList = dir('*.xlsx');
W0 = cell(4, 1);
W = cell(2,1);
for i = 1:length(fileList)
    filename = fileList(i).name;
    [Type, desc]=xlsfinfo(filename);
    sheetnumber=size(desc, 2); %返回表格文件中的sheet个数
    for k=1:sheetnumber
        W0{i,1}{k,1}=readmatrix(filename,'Sheet',desc{k});   % 读取文件的每一个sheet
    end
end
%将中间和右侧的剖面数据拼接成一整个沙坝-潟湖系统

W{1,1}{1,1}= W0{1,1}{1,1};%中间的剖面比右侧剖面多了最小波高的形态，由于右侧剖面未改变就没提取
W{2,1}{1,1}= W0{2,1}{1,1};
for i1 = 1:15
    W{1,1}{i1+1,1}=vertcat(W0{1,1}{i1+1,1},W0{3,1}{i1,1});
    W{2,1}{i1+1,1}=vertcat(W0{2,1}{i1+1,1},W0{4,1}{i1,1});
end

%按照真实植被布置情况沙坝（7.30~9.90m）、潟湖（9.90~11.80m）、前丘（11.80~13.20m）
area_diff1=zeros(16,1);area_diff2=zeros(16,1);area_diff3=zeros(16,1);
area_diff=zeros(16,1);
dep1=zeros(16,1);dep2=zeros(16,1);dep3=zeros(16,1);
d1=zeros(16,1);d2=zeros(16,1);d3=zeros(16,1);
ero1=zeros(16,1);ero2=zeros(16,1);ero3=zeros(16,1);
de1=zeros(16,1);de2=zeros(16,1);de3=zeros(16,1);
s_positive=zeros(16,1);l_positive=zeros(16,1);d_positive=zeros(16,1);
s_negative=zeros(16,1);l_negative=zeros(16,1);d_negative=zeros(16,1);
data_a={1,16};data_b={1,16};coastline=zeros(16,1);

for n=2:16
    x0=W{1,1}{n,1}(:,1);x1=W{2,1}{n,1}(:,1);
    y0=W{1,1}{n,1}(:,2);y1=W{2,1}{n,1}(:,2);
    m1=find(x0>=7.30 & x0<9.90);m2=find(x0>=9.90 & x0<11.80); m3=find(x0>=11.80 & x0<13.20);
    n1=find(x1>=7.30 & x1<9.90);n2=find(x1>=9.90 & x1<11.80); n3=find(x1>=11.80 & x1<13.20);
    x01=x0(m1);y01=y0(m1);x02=x0(m2);y02=y0(m2);x03=x0(m3);y03=y0(m3);
    x11=x1(n1);y11=y1(n1);x12=x1(n2);y12=y1(n2);x13=x1(n3);y13=y1(n3);

    xx0=vertcat(x01, x02, x03);yy0=vertcat(y01,y02,y03);%将沙坝潟湖前丘不同位置的数据组合
    xx1=vertcat(x11, x12, x13);yy1=vertcat(y11,y12,y13);
    z1=zeros();%理论的初始剖面数据
    for nn=1:length(xx1)
        if xx1(nn)<8.2
            z1(nn)=(0.5.*xx1(nn))-3.65;
        elseif xx1(nn)>=8.2 && xx1(nn)<9.2
            z1(nn)=0.45;
        elseif xx1(nn)>=9.2 && xx1(nn)<9.9
            z1(nn)=((-0.5).*xx1(nn))+5.05;
        elseif xx1(nn)>=9.9 && xx1(nn)<11.8
            z1(nn)=0.1;
        else
            z1(nn)=(0.5.*xx1(nn))-5.8;
        end
    end
    z1=z1';

    [cad_y13,idz13]=sort(y13);cad_x13=x13(idz13);%基于y排序，保证陡坎画图不会出问题

    %生成调换陡坎数据的画图使用的最终剖面形态
    cad_x=vertcat(x11,x12,cad_x13);
    cad_y=vertcat(y11,y12,cad_y13);
    %以下cad_x和cad_y数据为陡坎形式未失真时的数据
    xy0=[xx0 yy0];xyz1=[xx1 yy1 cad_x cad_y z1];

    %% 依次去除相邻的相同的x（陡坎处已经过排序）
    % 原始数组
    A ={[xx0 yy0];[cad_x cad_y]};
    % 提取x坐标
    x = {xx0;cad_x};
    filtered_A={2,1};
    for ii=1:2
        % 初始化结果数组
        filtered_A{ii,1} = [];
        % 遍历x坐标
        i2 = 1;
        while i2 <= length(x{ii})
            % 当前x值
            current_x = x{ii}(i2);
            % 添加当前点到结果数组
            filtered_A{ii,1} = [filtered_A{ii,1}; A{ii}(i2, :)];
            % 寻找下一个不同的x值
            j = i2 + 1;
            while j <= length(x{ii}) && x{ii}(j) == current_x
                j = j + 1;
            end
            % 更新下一个起始点
            i2 = j;
        end
    end
    z0x=filtered_A{1,1}(:,1);z0y=filtered_A{1,1}(:,2);%初始去除重复x点的剖面坐标
    z1x=filtered_A{2,1}(:,1);z1y=filtered_A{2,1}(:,2);%去除重复x点的冲刷后剖面坐标

    zz1=[z0x z0y];zz2= [z1x z1y];%第一次去除重复x坐标的数据

    %% 去除两列数据中不同的横坐标数据且前后剖面作差
    data_a{n} = zz1(ismember(zz1(:,1), zz2(:,1)), :);
    data_b{n} = zz2(ismember(zz2(:,1), zz1(:,1)), :);

    % 初始化差值结果
    diff_values = zeros(size(data_a{n}, 1), 1);
    diff_values2 = zeros(size(data_a{n}, 1), 1);%用来求最大冲刷深度，不考虑陡坎结构的凸面
    % 遍历每个横坐标点
    for i = 1:size(data_a{n}, 1)
        % 获取b曲线中对应的纵坐标值
        b_y_values = data_b{n}(data_b{n}(:, 1) == data_a{n}(i, 1), 2);

        % 根据不同情况计算差值
        if isempty(b_y_values)
            % b曲线中无对应纵坐标值时，将差值设为NaN，前面用了ismember函数处理，这里应该不会出现空了
            diff_values(i) = NaN;
        elseif length(b_y_values) == 1
            % b曲线中一个纵坐标值时
            diff_values2(i) = data_a{n}(i, 2) - b_y_values;
            diff_values(i) = data_a{n}(i, 2) - b_y_values;
        elseif length(b_y_values) == 2
            % b曲线中两个纵坐标值时
            b_sorted = sort(b_y_values, 'descend');
            diff_values2(i) = data_a{n}(i, 2) - b_sorted(2);
            diff_values(i) = data_a{n}(i, 2) - b_sorted(2);
        elseif length(b_y_values) == 3
            % b曲线中三个纵坐标值时
            b_sorted = sort(b_y_values, 'descend');
            diff_values2(i) = data_a{n}(i, 2) - b_sorted(3);
            diff_values(i) = data_a{n}(i, 2) - b_sorted(3);
            diff_values(i) = diff_values(i) - (b_sorted(1) - b_sorted(2));
        else
            b_sorted = sort(b_y_values, 'descend');
            diff_values2(i) = data_a{n}(i, 2) - b_sorted(end);
            diff_values(i) = data_a{n}(i, 2) - b_sorted(end);
            avg = mean(b_sorted(2:end-1));
            diff_values(i) = diff_values(i) - (b_sorted(end)-avg);
        end
    end

    % 输出结果
    newzx=data_a{n}(:, 1);newz1y=data_a{n}(:, 2);%冲刷前初始剖面数据
    newzy=diff_values;%前后差值，基于前述做差代码：横坐标与冲刷前数据相同，用于求取输沙量
    newzy_1=diff_values2;%用于求取最大淤积、冲刷厚度
    newz2x=data_b{n}(:, 1);newz2y=data_b{n}(:, 2);%冲刷后的剖面数据

    o1=find(newzx>=7.30 & newzx<9.90);
    o2=find(newzx>=9.90 & newzx<11.80);
    o3=find(newzx>=11.80 & newzx<13.20);
    oo1=find(newz2x>=7.30 & newz2x<9.90);
    oo2=find(newz2x>=9.90 & newz2x<11.80);
    oo3=find(newz2x>=11.80 & newz2x<13.20);
    zx1=newzx(o1);zx2=newzx(o2);zx3=newzx(o3);%处理后的三个区域的横坐标
    z01=newzy(o1);z02=newzy(o2);z03=newzy(o3);%前后做差，横坐标与处理前相同
    z01_1=newzy_1(o1);z02_1=newzy_1(o2);z03_1=newzy_1(o3);%用于求取最大淤积冲刷厚度
    zy1=newz1y(o1);zy2=newz1y(o2);zy3=newz1y(o3);%冲刷前纵坐标
    zx21=newz2x(oo1);zx22=newz2x(oo2);zx23=newz2x(oo3);%冲刷后横坐标
    zy21=newz2y(oo1);zy22=newz2y(oo2);zy23=newz2y(oo3);%冲刷后纵坐标

    %% 求最大淤积厚度与最大冲刷深度并存储
    [yzdep1,id1]=max(z01_1);[yzdep2,id2]=max(z02_1);[yzdep3,id3]=max(z03_1);
    [yzero1,ide1]=min(z01_1);[yzero2,ide2]=min(z02_1);[yzero3,ide3]=min(z03_1);

    dep1(n,1)=yzdep1; dep2(n,1)=yzdep2; dep3(n,1)=yzdep3;%最大淤积厚度
    d1(n,1)=id1;d2(n,1)=id2;d3(n,1)=id3;
    ero1(n,1)=yzero1; ero2(n,1)=yzero2; ero3(n,1)=yzero3;%最大冲刷深度
    de1(n,1)=ide1;de2(n,1)=ide2;de3(n,1)=ide3;
    %% 求输沙量：淤积量、侵蚀量
    sa=zeros();la=zeros();da=zeros();
    for si=2:length(zx1)
        sa(si-1)=z01(si)*(zx1(si)-zx1(si-1));
    end
    for li=2:length(zx2)
        la(li-1)=z02(li)*(zx2(li)-zx2(li-1));
    end
    for di=2:length(zx3)
        da(di-1)=z03(di)*(zx3(di)-zx3(di-1));
    end

    % 所有数的和,也就是三部分的总输沙量
    area_diff1(n) = sum(sa);area_diff2(n) = sum(la);area_diff3(n) = sum(da);
    area_diff(n)=area_diff1(n)+area_diff2(n)+area_diff3(n);
    % 正值的和，也就是三部分的侵蚀量
    positive_sa = sa(sa > 0);s_positive(n) = sum(positive_sa);
    positive_la = la(la > 0);l_positive (n)= sum(positive_la);
    positive_da = da(da > 0);d_positive(n) = sum(positive_da);

    % 负值的和，也就是三部分的淤积量
    negative_sa= sa(sa < 0);s_negative (n)= sum(negative_sa);
    negative_la= la(la < 0);l_negative (n)= sum(negative_la);
    negative_da= da(da < 0);d_negative (n)= sum(negative_da);

    %% 岸线蚀退距离计算
    data1=data_a{n}(o3,2);
    data2=data_b{n}(oo3,2);
    % 指定一个目标数值
    if n<=5
        target = 0.4;
    elseif n<=10
        target=0.45;
    else
        target=0.5;
    end
    % 计算每个数与目标数值的差的绝对值
    diff1 = abs(data1 - target);
    diff2= abs(data2 - target);
    % 找到最小的差值
    minDiff1 = min(diff1);
    minDiff2 = min(diff2);
    % 找到所有最小差值对应的索引
    indices1 = find(diff1 == minDiff1);
    indices2 = find(diff2 == minDiff2);
    coastline(n)=mean(data_b{n}(indices2,1))-mean(data_a{n}(indices1,1));

    %% 存储数据进excel
    writematrix(xy0, 'data0.xlsx', ...
        'Sheet', n,'Range',sprintf('%s%d', 'A', 2));%将原始初始剖面保存
    writematrix(xyz1, 'data0.xlsx', ...
        'Sheet', n,'Range',sprintf('%s%d', 'C', 2));%将原始最终剖面及理论初始剖面保存
    %将去除每条剖面曲线散点重复的点后又去除冲刷前后不对应的点后的数据存入
    writematrix([zx21 zy21], 'data0.xlsx', ...
        'Sheet', n,'Range',sprintf('%s%d', 'H', 2));%沙坝剖面段
    writematrix([zx22 zy22], 'data0.xlsx', ...
        'Sheet', n,'Range',sprintf('%s%d', 'J', 2));%潟湖剖面段
    writematrix([zx23 zy23], 'data0.xlsx', ...
        'Sheet', n,'Range',sprintf('%s%d', 'L', 2));%前丘剖面段
end
%依次存入沙坝、潟湖、前丘淤积量、侵蚀量、总输沙量；沙坝、潟湖、前丘最大淤积厚度和标记位置，以及其最大冲刷深度及标记位置
statistics=[s_positive l_positive d_positive s_negative l_negative d_negative...
    area_diff1 area_diff2 area_diff3 area_diff coastline ...
    dep1 dep2 dep3 ero1 ero2 ero3];
writematrix(statistics, 'sediment-statistics.xlsx',...
    'Sheet', 1, 'Range', sprintf('%s%d', 'B', 2));

save W;


