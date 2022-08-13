
----------mashaghel ostan report 1401/05/19----------
declare @ServerIP nvarchar(15)
declare _Cursor cursor for
select distinct  xServerIP from Taj_Tb_Servers 

open _Cursor
fetch next from _Cursor
into @ServerIP

while @@FETCH_STATUS = 0
begin
    declare @Query nvarchar(max) 
	set @Query='insert into [10.44.3.194].Amar_1401_03_07.dbo.MashTable select k.Cod_Hozeh,k.K_Parvand,k.sal,m.cod_meli,m.namee+''''+m.family as name from  ['+@ServerIP+'].mashaghel.dbo.shog_inf sh '+
	'inner join ['+@ServerIP+'].mashaghel.dbo.KMLink_Inf k on sh.cod_hozeh=k.Cod_Hozeh and sh.k_parvand=k.K_Parvand '+
	'inner join  ['+@ServerIP+'].mashaghel.dbo.modi_inf m on m.modi_seq=k.Modi_Seq '+
	'inner join  ['+@ServerIP+'].mashaghel.dbo.tashkhis_inf t on t.modi_seq=k.Modi_Seq '+
	'where k.Cod_Hozeh/100 in(select xedare from Taj_Tb_Servers where xServerIP='''+@ServerIP+''') '+
	'order by k.Cod_Hozeh,cast(replace(k.K_Parvand,''/'','''')as bigint),k.sal '
	print (@Query)

	fetch next from _Cursor
	into @ServerIP
end

close _Cursor
deallocate _Cursor

