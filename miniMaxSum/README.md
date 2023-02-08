# Problema: miniMaxSum

## Descrição
Dado um array de n números inteiros, encontre o valor mínimo e o valor máximo da soma de n-1 deles.

## Exemplo de entrada e saída

    Entrada: 1 2 3 4 5
    Saída: 10 14

## Observações
    Todos os números são distintos.


# Solução sem vunit
Para rodar a solução siga os seguintes comandos

```shell
ghdl -a ../stream_bfm.vhd miniMaxSum.vhd miniMaxSum_tb.vhd
ghdl -e miniMaxSum_tb
ghdl -r miniMaxSum_tb
```
