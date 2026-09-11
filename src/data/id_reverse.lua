local ok, generated = pcall(require, "data.generated.id_reverse")
if not ok then
    generated = { units = {}, abilities = {}, items = {}, buffs = {} }
end

return generated
