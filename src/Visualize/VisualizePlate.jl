


function plot(design::PlateArray;pos="blue",neg="red",inactive="darkgray")

        plt=plot()
        nrow,ncol=size(design.plate)
        xlims!((0.5,ncol+0.5))
        ylims!((0.5,nrow+0.5))
        hlines=collect(0:nrow) .+ 0.5
        vlines=collect(0:ncol) .+ 0.5
        for line in hlines
            hline!([line],color="black")
        end 
        for line in vlines
            vline!([line],color="black")
        end
        for idx in Tuple.(CartesianIndices(design.plate))
            x,y=idx
            if !design.plate[x,y]
                plot!(rectangle(y-0.5,x-0.5,1,1),fillcolor=inactive)
            end 
            if design.pos[x,y]
                plot!(rectangle(y-0.5,x-0.5,1,1),fillcolor=pos)
            end 
            if design.neg[x,y]
                plot!(rectangle(y-0.5,x-0.5,1,1),fillcolor=neg)
            end 
        end 
       
        
        plot!(title="",legend=false,grid=false,yflip=true,yticks=(collect(1:nrow),alphabet_code.(1:nrow)),ytickdirection=:none,xticks=collect(1:ncol),xmirror=true,xtickdirection=:none)
end 

function alphabet_code(n) 
    
    alphabet=collect('A':'Z')
    k=length(alphabet)
    return repeat(alphabet[mod(n-1,k)+1],cld(n,k))
end 


function rectangle(x,y,w,h)
    return Shape(x .+ [0,w,w,0],y .+ [0,0,h,h])
end 


