function data = config(field,option)
    arguments
        field  = [];
        option = 'merge';
    end

    userpath = SystemFunc.getpath('config.json');
    syspath = SystemFunc.getpath('+SystemConfig','config.json');

    if isfile(userpath)
        user = readstruct(userpath);
    else
        user = struct();
    end
    
    sys = readstruct(syspath);
    
    switch option
        case 'merge'
            data = merge(sys,user,{});
        case 'system'
            data = sys;
        case 'user'
            data = user;
    end

    if ~isempty(field)
        data = data.(field);
    end

end

function data = merge(data,user,fn)
    if isempty(fn)
        user_i = user;
    else
        user_i = getfield(user,fn{:});
    end
    
    if isstruct(user_i)
        fnames = fieldnames(user_i);
        for i = 1:numel(fnames)
            data_i = getfield(data,fn{:},fnames{i});
            if isscalar(data_i)
                data = merge(data,user,[fn,fnames(i)]);
            else
                user_ii = user_i.(fnames{i});
                for j = 1:numel(data_i)
                    idx = arrayfun(@(ii) isequal(user_ii(ii),data_i(j)), 1:numel(user_ii) );
                    user_ii(idx) = [];
                end
                
                try
                    data = setfield(data,fn{:},fnames{i},[data_i,user_ii]);
                catch
                    error('The field names in the structure are different.')
                end
            end
        end
    else
        data = setfield(data,fn{:},user_i);
    end
end




