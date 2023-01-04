
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

| secid        | name                      | is_traded | type            | primary_boardid |
|:-------------|:--------------------------|----------:|:----------------|:----------------|
| SBER         | Сбербанк России ПАО ао    |         1 | common_share    | TQBR            |
| SBERP        | Сбербанк России ПАО ап    |         1 | preferred_share | TQBR            |
| RU000A103WV8 | Сбербанк ПАО 001Р-SBER33  |         1 | exchange_bond   | TQCB            |
| RU000A102RS6 | Сбербанк ПАО 001Р-SBER24  |         1 | exchange_bond   | TQCB            |
| RU000A101QW2 | Сбербанк ПАО 001Р-SBER16  |         1 | exchange_bond   | TQCB            |
| RU000A101C89 | Сбербанк ПАО 001Р-SBER15  |         1 | exchange_bond   | TQCB            |
| RU000A102CU4 | Сбербанк ПАО 001Р-SBER19  |         1 | exchange_bond   | TQCB            |
| RU000A1025U5 | Сбербанк ПАО 001Р-SBER17  |         1 | exchange_bond   | TQCB            |
| RU000A103YM3 | Сбербанк ПАО 002Р-green01 |         1 | exchange_bond   | TQCB            |
| RU000A0ZZ117 | Сбербанк ПАО БО 001Р-06R  |         1 | exchange_bond   | TQCB            |

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
| SBER  | TQBR    | Т+: Акции и ДР - безадрес.                 |         1 | 2013-03-25   | 2023-01-03   | RUB        |
| SBER  | EQBR    | Основной режим: А1-Акции и паи - безадрес. |         0 | 2011-11-21   | 2013-08-30   | RUB        |
| SBER  | SPEQ    | Поставка по СК (акции)                     |         1 | 2018-06-29   | 2022-12-16   | RUB        |
| SBER  | SMAL    | Т+: Неполные лоты (акции) - безадрес.      |         1 | 2011-11-21   | 2023-01-03   | RUB        |
| SBER  | TQDP    | Крупные пакеты - Акции - безадрес.         |         1 | NA           | NA           | RUB        |
| SBER  | EQDP    | Крупные пакеты - Акции - безадрес.         |         0 | 2011-12-12   | 2019-03-01   | RUB        |
| SBER  | RPMO    | РЕПО-М - адрес.                            |         1 | 2019-04-22   | 2023-01-03   | RUB        |
| SBER  | PTEQ    | РПС с ЦК: Акции и ДР - адрес.              |         1 | 2013-03-26   | 2023-01-03   | RUB        |
| SBER  | MXBD    | MOEX Board                                 |         0 | 2015-08-03   | 2023-01-04   | NA         |
| SBER  | CLMR    | Classica - безадрес.                       |         0 | 2012-02-13   | 2015-07-31   | RUB        |

Fetch the `SBER` candles:

``` r
get_candles(secid = 'SBER', from = '2020-01-01', till = '2022-01-01', interval = 'monthly') |> 
    head()
```

| secid |   open |  close |   high |    low |        value |     volume | begin      | end        |
|:------|-------:|-------:|-------:|-------:|-------------:|-----------:|:-----------|:-----------|
| SBER  | 255.99 | 252.20 | 270.80 | 251.40 | 194032391970 |  747137520 | 2020-01-01 | 2020-01-31 |
| SBER  | 251.80 | 233.36 | 259.77 | 231.00 | 229515686975 |  919822790 | 2020-02-01 | 2020-02-28 |
| SBER  | 238.93 | 187.21 | 241.00 | 172.15 | 585178686681 | 3001736660 | 2020-03-01 | 2020-03-31 |
| SBER  | 183.20 | 197.25 | 205.44 | 182.00 | 339626472208 | 1768222700 | 2020-04-01 | 2020-04-30 |
| SBER  | 195.68 | 200.50 | 205.00 | 183.33 | 262827471698 | 1359045230 | 2020-05-01 | 2020-05-29 |
| SBER  | 203.10 | 203.22 | 223.15 | 200.75 | 320424161576 | 1522268370 | 2020-06-01 | 2020-06-30 |

`get_candles()` is vectorised over `secid`, so it is possible to, say,
fetch candles for both the common and the preferred shares. The returned
object has class `MoexCandles` for which there’s an appropriate `plot()`
method:

``` r
get_candles(
    secid = c('SBER', 'SBERP'), 
    from = '2020-01-01', 
    till = '2022-01-01', 
    interval = 'monthly'
) |> 
    plot()
```

![](man/figures/README-unnamed-chunk-6-1.png)<!-- -->
