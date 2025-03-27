local data = {}

function getAll()
    return data
end

function getData(index, key)
    return key and data[index][key] or data[index]
end

function setData(index, key, value)
    if (not data[index]) then
        data[index] = {}
    end
    data[index][key] = value
end

function clearData(index)
    data[index] = nil
end

exports = {
    getAll = getAll,
    get = getData,
    set = setData,
    clear = clearData
}