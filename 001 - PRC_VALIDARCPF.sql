use Toolbox
go

If Exists (Select 1 From sysobjects Where name = 'PRC_VALIDARCPF')
	Drop Procedure PRC_VALIDARCPF
go

CREATE PROCEDURE dbo.PRC_VALIDARCPF @p_cpf VarChar(14), @p_retorno Bit Output, @p_mensagem VarChar(100) Output
AS
SET NOCOUNT ON
/*
Fórmula para validação de CPF no formato abc.def.ghi-xy

Parâmetros:
    @p_cpf      = CPF no formatado ou não, obrigatório os dois dígitos de controle
    @p_retorno  = 0 -> Inválido ou 1 -> Válido
    @p_mensagem = Complemento ao parâmetro @p_retorno

Exemplo:
    Declare @retorno bit, @mensagem VarChar(100)
    exec PRC_VALIDARCPF @p_cpf = '299.822.378-88', @p_retorno = @retorno Output, @p_mensagem = @mensagem Output
    Select @retorno Retorno, @mensagem Mensagem
*/

Begin
    Declare @a int,
            @b int,
            @c int,
            @d int,
            @e int,
            @f int,
            @g int,
            @h int,
            @i int,
            @x int,
            @y int,
            @ctrl1 int,
            @ctrl2 int,
            @cpf varchar(14)

    --Zera variaveis de retorno
    Select @p_retorno = 0, @p_mensagem = ''

    --Formata o CPF recebido
    Select @cpf = @p_cpf
    Select @cpf = REPLACE(@cpf,'.','')
    Select @cpf = REPLACE(@cpf,'-','')

    If left(@cpf,9) in ('000000000', '111111111', '222222222', '333333333', '444444444',
                        '555555555', '666666666', '777777777', '888888888', '999999999')
        or ltrim(rtrim(isnull(@cpf,''))) = ''
        Begin
            Select @p_retorno = 0, @p_mensagem = 'CPF Inválido.'
            Return
        End

    --Separa as posicoes antes do calculo dos digitos de controle
    Select @a = left(@cpf, 1)
    Select @b = substring(@cpf, 2,  1)
    Select @c = substring(@cpf, 3,  1)
    Select @d = substring(@cpf, 4,  1)
    Select @e = substring(@cpf, 5,  1)
    Select @f = substring(@cpf, 6,  1)
    Select @g = substring(@cpf, 7,  1)
    Select @h = substring(@cpf, 8,  1)
    Select @i = substring(@cpf, 9,  1)
    Select @x = substring(@cpf, 10, 1)
    Select @y = substring(@cpf, 11, 1)

    --Calculo do primeiro digito de controle (x)
    Select @ctrl1 = (@a * 10 + @b * 9 + @c * 8 + @d * 7 + @e * 6 + @f * 5 + @g * 4 + @h * 3 + @i * 2)
    Select @ctrl1 = @ctrl1 * 10 % 11
    If @ctrl1 = 10 
        Select @ctrl1 = 0

    If @x <> @ctrl1
        Begin
            Select @p_retorno = 0, @p_mensagem = 'Primeiro digito não confere.'
            Return
        End
    
    --Calculo do segundo digito de controle (y)
    Select @ctrl2 = (@a * 11 + @b * 10 + @c * 9 + @d * 8 + @e * 7 + @f * 6 + @g * 5 + @h * 4 + @i * 3 + @ctrl1 * 2)
    Select @ctrl2 = @ctrl2 * 10 % 11
    If @ctrl2 = 10 
        Select @ctrl2 = 0

    If @y <> @ctrl2
        Begin
            Select @p_retorno = 0, @p_mensagem = 'Segundo digito não confere.'
            Return
        End


    Select @p_retorno = 1, @p_mensagem = 'CPF Válido.'
    Return    
end
