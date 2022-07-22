
<!-- README.md is generated from README.Rmd. Please edit that file -->

# moexer

<!-- badges: start -->
<!-- badges: end -->

Moscow Exchange (MOEX) provides a REST interface to its Informational
and Statistical Server (ISS), see <https://fs.moex.com/files/8888>.

`moexer` is a thin wrapper around the REST interface. It allows to
quickly fetch e.g. price candles for a particular security, obtain its
profile information and so on. The data is returned as `tibble`s, making
it easy to subsequently process and analyse it.

## Installation

You can install the released version of moexer from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("moexer")
```

or the latest version from github:

``` r
devtools::install_github("x1o/moexer")
```

## Example

Suppose you want to download monthly candles from Jan 1, 2020 until the
present day for the Sberbank common shares.

``` r
library(moexer)
library(dplyr)
```

Each security on MOEX has an ID, e.g. a 4-letter ticker symbol for a
share (“LKOH”) or an ISIN for a bond (“RU000A0JXPU3”).

Find the corresponding security ID:

``` r
search_security(query = 'Sberbank') |> 
    slice_head(n = 10) |> 
    select(secid, name, is_traded, type, primary_boardid)
```

| secid    | name                           | is_traded | type            | primary_boardid |
|:---------|:-------------------------------|----------:|:----------------|:----------------|
| SBER     | Сбербанк России ПАО ао         |         1 | common_share    | TQBR            |
| SBERP    | Сбербанк России ПАО ап         |         1 | preferred_share | TQBR            |
| SRU2     | Фьючерсный контракт SBRF-9.22  |         1 | futures         | RFUD            |
| SRM2     | Фьючерсный контракт SBRF-6.22  |         0 | futures         | RFUD            |
| SPU2     | Фьючерсный контракт SBPR-9.22  |         1 | futures         | RFUD            |
| SRZ2     | Фьючерсный контракт SBRF-12.22 |         1 | futures         | RFUD            |
| SPM2     | Фьючерсный контракт SBPR-6.22  |         0 | futures         | RFUD            |
| RLU2     | Фьючерсный контракт RUAL-9.22  |         1 | futures         | RFUD            |
| RLM2     | Фьючерсный контракт RUAL-6.22  |         0 | futures         | RFUD            |
| RUAL_CLT | RUAL_CLT                       |         0 | futures         | RFUD            |

We can verify that `SBER` is indeed the symbol we were looking for and
check the profile information:

``` r
sber_info <- get_security_info(secid = 'SBER')
sber_info$description |> 
    select(name, title, value)
```

| name                 | title                                            | value                  |
|:---------------------|:-------------------------------------------------|:-----------------------|
| SECID                | Код ценной бумаги                                | SBER                   |
| NAME                 | Полное наименование                              | Сбербанк России ПАО ао |
| SHORTNAME            | Краткое наименование                             | Сбербанк               |
| ISIN                 | ISIN код                                         | RU0009029540           |
| REGNUMBER            | Номер государственной регистрации                | 10301481B              |
| ISSUESIZE            | Объем выпуска                                    | 21586948000            |
| FACEVALUE            | Номинальная стоимость                            | 3                      |
| FACEUNIT             | Валюта номинала                                  | SUR                    |
| ISSUEDATE            | Дата начала торгов                               | 2007-07-20             |
| LATNAME              | Английское наименование                          | Sberbank               |
| LISTLEVEL            | Уровень листинга                                 | 1                      |
| ISQUALIFIEDINVESTORS | Бумаги для квалифицированных инвесторов          | 0                      |
| MORNINGSESSION       | Допуск к утренней дополнительной торговой сессии | 1                      |
| EVENINGSESSION       | Допуск к вечерней дополнительной торговой сессии | 1                      |
| TYPENAME             | Вид/категория ценной бумаги                      | Акция обыкновенная     |
| GROUP                | Код типа инструмента                             | stock_shares           |
| TYPE                 | Тип бумаги                                       | common_share           |
| GROUPNAME            | Типа инструмента                                 | Акции                  |
| EMITTER_ID           | Код эмитента                                     | 1199                   |

``` r
sber_info$boards |> 
    slice_head(n = 10) |> 
    select(secid, boardid, title, is_traded, history_from, history_till, currencyid)
```

| secid | boardid | title                                      | is_traded | history_from | history_till | currencyid |
|:------|:--------|:-------------------------------------------|----------:|:-------------|:-------------|:-----------|
| SBER  | TQBR    | Т+: Акции и ДР - безадрес.                 |         1 | 2013-03-25   | 2022-07-21   | RUB        |
| SBER  | EQBR    | Основной режим: А1-Акции и паи - безадрес. |         0 | 2011-11-21   | 2013-08-30   | RUB        |
| SBER  | SPEQ    | Поставка по СК (акции)                     |         1 | 2018-06-29   | 2022-06-17   | RUB        |
| SBER  | SMAL    | Т+: Неполные лоты (акции) - безадрес.      |         1 | 2011-11-21   | 2022-07-21   | RUB        |
| SBER  | TQDP    | Крупные пакеты - Акции - безадрес.         |         1 | NA           | NA           | RUB        |
| SBER  | EQDP    | Крупные пакеты - Акции - безадрес.         |         0 | 2011-12-12   | 2019-03-01   | RUB        |
| SBER  | RPMO    | РЕПО-М - адрес.                            |         1 | 2019-04-22   | 2022-07-21   | RUB        |
| SBER  | PTEQ    | РПС с ЦК: Акции и ДР - адрес.              |         1 | 2013-03-26   | 2022-07-21   | RUB        |
| SBER  | MXBD    | MOEX Board                                 |         0 | 2015-08-03   | 2022-07-21   | NA         |
| SBER  | CLMR    | Classica - безадрес.                       |         0 | 2012-02-13   | 2015-07-31   | RUB        |

Fetch the `SBER` candles:

``` r
get_candles(secid = 'SBER', from = '2020-01-01', interval = 'monthly')
```

| secid |   open |  close |   high |    low |        value |     volume | begin      | end        |
|:------|-------:|-------:|-------:|-------:|-------------:|-----------:|:-----------|:-----------|
| SBER  | 255.99 | 252.20 | 270.80 | 251.40 | 1.940324e+11 |  747137520 | 2020-01-01 | 2020-01-31 |
| SBER  | 251.80 | 233.36 | 259.77 | 231.00 | 2.295157e+11 |  919822790 | 2020-02-01 | 2020-02-28 |
| SBER  | 238.93 | 187.21 | 241.00 | 172.15 | 5.851787e+11 | 3001736660 | 2020-03-01 | 2020-03-31 |
| SBER  | 183.20 | 197.25 | 205.44 | 182.00 | 3.396265e+11 | 1768222700 | 2020-04-01 | 2020-04-30 |
| SBER  | 195.68 | 200.50 | 205.00 | 183.33 | 2.628275e+11 | 1359045230 | 2020-05-01 | 2020-05-29 |
| SBER  | 203.10 | 203.22 | 223.15 | 200.75 | 3.204242e+11 | 1522268370 | 2020-06-01 | 2020-06-30 |
| SBER  | 205.00 | 221.57 | 221.98 | 197.73 | 2.318350e+11 | 1088082960 | 2020-07-01 | 2020-07-31 |
| SBER  | 222.27 | 226.10 | 244.04 | 221.30 | 3.072406e+11 | 1324478990 | 2020-08-01 | 2020-08-31 |
| SBER  | 226.70 | 229.14 | 232.60 | 215.79 | 3.159648e+11 | 1402033750 | 2020-09-01 | 2020-09-30 |
| SBER  | 229.08 | 200.99 | 229.90 | 200.50 | 3.105482e+11 | 1488757060 | 2020-10-01 | 2020-10-31 |
| SBER  | 200.45 | 249.63 | 252.88 | 196.15 | 5.445536e+11 | 2310960320 | 2020-11-01 | 2020-11-30 |
| SBER  | 250.75 | 271.65 | 287.74 | 249.80 | 4.501684e+11 | 1660369550 | 2020-12-01 | 2020-12-31 |
| SBER  | 274.67 | 258.11 | 296.07 | 257.36 | 4.051870e+11 | 1471411670 | 2021-01-01 | 2021-01-30 |
| SBER  | 260.00 | 270.17 | 276.48 | 258.55 | 3.467756e+11 | 1291107150 | 2021-02-01 | 2021-02-27 |
| SBER  | 273.00 | 291.02 | 295.72 | 271.13 | 3.880939e+11 | 1365301070 | 2021-03-01 | 2021-03-31 |
| SBER  | 292.00 | 297.73 | 301.84 | 278.00 | 3.486348e+11 | 1207909680 | 2021-04-01 | 2021-04-30 |
| SBER  | 298.70 | 310.79 | 320.19 | 293.00 | 3.000384e+11 |  980301170 | 2021-05-01 | 2021-05-31 |
| SBER  | 312.60 | 306.45 | 316.58 | 303.34 | 2.180186e+11 |  699844320 | 2021-06-01 | 2021-06-30 |
| SBER  | 306.00 | 305.59 | 308.37 | 290.03 | 1.824998e+11 |  605448260 | 2021-07-01 | 2021-07-31 |
| SBER  | 306.23 | 327.94 | 338.99 | 306.06 | 2.446005e+11 |  753896990 | 2021-08-01 | 2021-08-31 |
| SBER  | 328.87 | 340.99 | 342.20 | 322.39 | 2.648336e+11 |  804222750 | 2021-09-01 | 2021-09-30 |
| SBER  | 339.21 | 356.14 | 388.11 | 336.08 | 3.611963e+11 |  985879080 | 2021-10-01 | 2021-10-30 |
| SBER  | 356.15 | 315.00 | 374.00 | 300.10 | 4.678729e+11 | 1403354360 | 2021-11-01 | 2021-11-30 |
| SBER  | 321.30 | 293.49 | 329.44 | 261.50 | 5.933216e+11 | 1995808660 | 2021-12-01 | 2021-12-31 |
| SBER  | 295.90 | 269.42 | 310.10 | 221.03 | 1.078002e+12 | 4242270550 | 2022-01-01 | 2022-01-31 |
| SBER  | 269.72 | 131.12 | 282.30 |  89.59 | 1.319073e+12 | 6067441240 | 2022-02-01 | 2022-02-26 |
| SBER  | 131.00 | 143.69 | 156.20 | 122.00 | 6.551515e+10 |  476778920 | 2022-03-01 | 2022-03-31 |
| SBER  | 145.00 | 128.80 | 169.90 | 111.50 | 2.167699e+11 | 1593570460 | 2022-04-01 | 2022-04-30 |
| SBER  | 129.10 | 118.30 | 131.50 | 117.10 | 8.752642e+10 |  709098740 | 2022-05-01 | 2022-05-31 |
| SBER  | 117.50 | 125.20 | 142.35 | 115.80 | 1.370268e+11 | 1070107420 | 2022-06-01 | 2022-06-30 |
| SBER  | 124.13 | 128.60 | 137.10 | 122.24 | 9.197581e+10 |  712452040 | 2022-07-01 | 2022-07-22 |

`get_candles()` is vectorised over `secid`, so it is possible to, say,
fetch candles for both the common and the preferred shares:

``` r
get_candles(secid = c('SBER', 'SBERP'), from = '2020-01-01', interval = 'monthly') |> 
    plot_candles()
```

![](man/figures/README-unnamed-chunk-6-1.png)<!-- -->
