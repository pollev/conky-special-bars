--paths-must-be->/home/worldchampions/.conky/...
--not--> ~/
function conky_main()
    dofile ('/home/polle/.conky/draw_bg.lua')
    dofile ('/home/polle/.conky/special_bars.lua')

    --call of the main functions in the lua files
    conky_draw_bg()
    conky_special_bars()

end
