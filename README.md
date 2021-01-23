
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
search_security(query = 'Sberbank') %>% 
    slice_head(n = 10) %>% 
    select(secid, name, is_traded, type, primary_boardid)
```

<div class="kable-table">

| secid      | name                           | is\_traded | type             | primary\_boardid |
| :--------- | :----------------------------- | ---------: | :--------------- | :--------------- |
| SBER       | Сбербанк России ПАО ао         |          1 | common\_share    | TQBR             |
| SBERP      | Сбербанк России ПАО ап         |          1 | preferred\_share | TQBR             |
| SRH1       | Фьючерсный контракт SBRF-3.21  |          1 | futures          | RFUD             |
| SRZ0       | Фьючерсный контракт SBRF-12.20 |          0 | futures          | RFUD             |
| SPH1       | Фьючерсный контракт SBPR-3.21  |          1 | futures          | RFUD             |
| SPZ0       | Фьючерсный контракт SBPR-12.20 |          0 | futures          | RFUD             |
| SRM1       | Фьючерсный контракт SBRF-6.21  |          1 | futures          | RFUD             |
| SBERP\_CLT | SBERP\_CLT                     |          0 | futures          | RFUD             |
| SBER\_CLT  | SBER\_CLT                      |          0 | futures          | RFUD             |
| SPM1       | Фьючерсный контракт SBPR-6.21  |          1 | futures          | RFUD             |

</div>

We can verify that `SBER` is indeed the symbol we were looking for and
check the profile information:

``` r
sber_info <- get_security_info(secid = 'SBER')
sber_info$description %>% 
    select(name, title, value)
```

<div class="kable-table">

| name                 | title                                   | value                  |
| :------------------- | :-------------------------------------- | :--------------------- |
| SECID                | Код ценной бумаги                       | SBER                   |
| NAME                 | Полное наименование                     | Сбербанк России ПАО ао |
| SHORTNAME            | Краткое наименование                    | Сбербанк               |
| ISIN                 | ISIN код                                | RU0009029540           |
| REGNUMBER            | Номер государственной регистрации       | 10301481B              |
| ISSUESIZE            | Объем выпуска                           | 21586948000            |
| FACEVALUE            | Номинальная стоимость                   | 3                      |
| FACEUNIT             | Валюта номинала                         | SUR                    |
| ISSUEDATE            | Дата начала торгов                      | 2007-07-20             |
| LATNAME              | Английское наименование                 | Sberbank               |
| LISTLEVEL            | Уровень листинга                        | 1                      |
| ISQUALIFIEDINVESTORS | Бумаги для квалифицированных инвесторов | 0                      |
| EVENINGSESSION       | Допуск к дополнительной торговой сессии | 1                      |
| TYPENAME             | Вид/категория ценной бумаги             | Акция обыкновенная     |
| GROUP                | Код типа инструмента                    | stock\_shares          |
| TYPE                 | Тип бумаги                              | common\_share          |
| GROUPNAME            | Типа инструмента                        | Акции                  |
| EMITTER\_ID          | Код эмитента                            | 1199                   |

</div>

``` r
sber_info$boards %>% 
    slice_head(n = 10) %>% 
    select(secid, boardid, title, is_traded, history_from, history_till, currencyid)
```

<div class="kable-table">

| secid | boardid | title                                      | is\_traded | history\_from | history\_till | currencyid |
| :---- | :------ | :----------------------------------------- | ---------: | :------------ | :------------ | :--------- |
| SBER  | TQBR    | Т+: Акции и ДР - безадрес.                 |          1 | 2013-03-25    | 2021-01-22    | RUB        |
| SBER  | EQBR    | Основной режим: А1-Акции и паи - безадрес. |          0 | 2011-11-21    | 2013-08-30    | RUB        |
| SBER  | SPEQ    | Поставка по СК (акции)                     |          1 | 2018-06-29    | 2020-12-18    | RUB        |
| SBER  | SMAL    | Т+: Неполные лоты (акции) - безадрес.      |          1 | 2011-11-21    | 2021-01-22    | RUB        |
| SBER  | TQDP    | Крупные пакеты - Акции - безадрес.         |          1 | NA            | NA            | RUB        |
| SBER  | EQDP    | Крупные пакеты - Акции - безадрес.         |          0 | 2011-12-12    | 2019-03-01    | RUB        |
| SBER  | RPMO    | РЕПО-М - адрес.                            |          1 | 2019-04-22    | 2021-01-22    | RUB        |
| SBER  | PTEQ    | РПС с ЦК: Акции и ДР - адрес.              |          1 | 2013-03-26    | 2021-01-22    | RUB        |
| SBER  | MXBD    | MOEX Board                                 |          0 | 2015-08-03    | 2021-01-22    | NA         |
| SBER  | CLMR    | Classica - безадрес.                       |          0 | 2012-02-13    | 2015-07-31    | RUB        |

</div>

Fetch the `SBER`
candles:

``` r
get_candles(secid = 'SBER', from = '2020-01-01', interval = 'monthly')
```

<div class="kable-table">

| secid |   open |  close |   high |    low |        value |     volume | begin      | end        |
| :---- | -----: | -----: | -----: | -----: | -----------: | ---------: | :--------- | :--------- |
| SBER  | 255.99 | 252.20 | 270.80 | 251.40 | 194032391970 |  747137520 | 2020-01-01 | 2020-01-31 |
| SBER  | 251.80 | 233.36 | 259.77 | 231.00 | 229515686975 |  919822790 | 2020-02-01 | 2020-02-28 |
| SBER  | 238.93 | 187.21 | 241.00 | 172.15 | 585178686681 | 3001736660 | 2020-03-01 | 2020-03-31 |
| SBER  | 183.20 | 197.25 | 205.44 | 182.00 | 339626472208 | 1768222700 | 2020-04-01 | 2020-04-30 |
| SBER  | 195.68 | 200.50 | 205.00 | 183.33 | 262827471698 | 1359045230 | 2020-05-01 | 2020-05-29 |
| SBER  | 203.10 | 203.22 | 223.15 | 200.75 | 320424161576 | 1522268370 | 2020-06-01 | 2020-06-30 |
| SBER  | 205.00 | 221.57 | 221.98 | 197.73 | 231835029801 | 1088082960 | 2020-07-01 | 2020-07-31 |
| SBER  | 222.27 | 226.10 | 244.04 | 221.30 | 307240595763 | 1324478990 | 2020-08-01 | 2020-08-31 |
| SBER  | 226.70 | 229.14 | 232.60 | 215.79 | 315964782288 | 1402033750 | 2020-09-01 | 2020-09-30 |
| SBER  | 229.08 | 200.99 | 229.90 | 200.50 | 310548235089 | 1488757060 | 2020-10-01 | 2020-10-31 |
| SBER  | 200.45 | 249.63 | 252.88 | 196.15 | 544553568624 | 2310960320 | 2020-11-01 | 2020-11-30 |
| SBER  | 250.75 | 271.65 | 287.74 | 249.80 | 450168396193 | 1660369550 | 2020-12-01 | 2020-12-31 |
| SBER  | 274.67 | 268.25 | 296.07 | 266.78 | 274786926946 |  980382340 | 2021-01-01 | 2021-01-23 |

</div>

`get_candles()` is vectorised over `secid`, so it is possible to, say,
fetch candles for both the common and the preferred
shares:

``` r
get_candles(secid = c('SBER', 'SBERP'), from = '2020-01-01', interval = 'monthly') %>% 
    plot_candles()
```

![](man/figures/README-unnamed-chunk-6-1.png)<!-- -->
