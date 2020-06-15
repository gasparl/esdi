library("shiny")
library("shinythemes")
library("shinycssloaders")
library("ggplot2")
library("plotly")
library("neatStats")

nearnormal = function(n, mean = 0, sd = 1) {
    stats::qnorm(seq(1 / n, 1 - 1 / n, length.out = n), mean, sd)
}
hush = function(code) {
    sink("NUL")
    tmp = code
    sink()
    return(tmp)
}

### --- Accuracy vs. Effect

prep_sim = function(gg_start,
                    gg_end,
                    gg_step,
                    gi1_start,
                    gi1_end,
                    gi1_step,
                    sd_g,
                    sd_i,
                    N) {
    d_between_guilties = seq(gg_start, gg_end, by = gg_step)
    d_case_control = seq(gi1_start, gi1_end, by = gi1_step)
    col_names = c(
        "d_case1_vs_case2",
        "mean_1",
        "mean_2",
        "d_1",
        "d_2",
        "d_gain",
        "accuracy_1",
        "accuracy_2",
        "accuracy_gain",
        "AUC_1",
        "AUC_2",
        "AUC_gain"
    )
    results_table = data.frame(matrix(NA , nrow = 0, ncol = length(col_names)))
    colnames(results_table) = col_names
    for (d_gi0 in d_case_control) {
        for (d_gg0 in d_between_guilties) {
            mg1 = d_gi0 * (((sd_g ** 2 + sd_i ** 2) / 2) ** 0.5)
            mg2 = d_gg0 * (((sd_g ** 2 + sd_g ** 2) / 2) ** 0.5) + mg1
            case1 = nearnormal(n = N,
                               mean = mg1,
                               sd = sd_g)
            case2 = nearnormal(n = N,
                               mean = mg2,
                               sd = sd_g)
            control1 = nearnormal(n = N,
                                  mean = 0,
                                  sd = sd_i)
            control2 = nearnormal(n = N,
                                  mean = 0,
                                  sd = sd_i)
            
            gi1 = hush(t_neat(
                case1,
                control1,
                auc_added = T,
                bf_added = F,
                hush = T
            ))
            gi2 = hush(t_neat(
                case2,
                control2,
                auc_added = T,
                bf_added = F,
                hush = T
            ))
            d_gi1 = gi1$stats["d"]
            d_gi2 = gi2$stats["d"]
            auc1 = gi1$stats["auc"]
            auc2 = gi2$stats["auc"]
            acc1 = gi1$stats["accuracy"]
            acc2 = gi2$stats["accuracy"]
            d_gg = hush(t_neat(
                case2,
                case1,
                bf_added = F,
                hush = T
            )$stats["d"])
            results_table[nrow(results_table) + 1,] = c(
                d_gg,
                mg1,
                mg2,
                d_gi1,
                d_gi2,
                d_gi2 - d_gi1,
                auc1,
                auc2,
                auc2 - auc1,
                acc1,
                acc2,
                acc2 - acc1
            )
        }
    }
    return(results_table)
}


prep_plot = function(results_to_plot,
                     yval_opt,
                     ylabel_total ,
                     ylabel_gain ,
                     xlabel_all ,
                     legend_titl,
                     legend_var) {
    if (yval_opt == 'acc') {
        results_to_plot$yvals_1 = results_to_plot$accuracy_1
        results_to_plot$yvals_2 = results_to_plot$accuracy_2
        results_to_plot$yvals_gain = results_to_plot$accuracy_gain
        if (legend_var != 'd_1') {
            legend_var = 'accuracy_1'
            # TODO replace "Initial effect size:" with "Initial accuracy:" -- perhaps already when choosing it, interactively
        }
    } else {
        results_to_plot$yvals_1 = results_to_plot$AUC_1
        results_to_plot$yvals_2 = results_to_plot$AUC_2
        results_to_plot$yvals_gain = results_to_plot$AUC_gain
        if (legend_var != 'd_1') {
            legend_var = 'AUC_1'
            # TODO replace "Initial effect size:" with "Initial accuracy:"
        }
    }
    theplot = ggplot(data = results_to_plot,
                     aes(
                         x = d_case1_vs_case2,
                         group = yvals_1,
                         color = as.factor(yvals_1)
                     )) + theme_bw() +
        theme(
            panel.grid.minor = element_blank(),
            panel.grid.major = element_line(colour = "#e6e6e6", size = 0.5)
        ) +
        scale_color_grey(
            start = 0.7,
            end = 0.0,
            name = legend_titl,
            label = ro(levels(as.factor(
                results_to_plot[[legend_var]]
            )), 2)
        )
    hlines_comb = geom_hline(
        yintercept = seq(0.5, 1.0, by = 0.05),
        colour = "#e6e6e6",
        size = 0.5
    )
    hlines_tot = geom_hline(
        yintercept = seq(ceiling(min(
            results_to_plot$yvals_2
        ) * 10) / 10,
        max(results_to_plot$yvals_2),
        by = 0.05),
        colour = "#e6e6e6",
        size = 0.5
    )
    hlines_gain = geom_hline(
        yintercept = seq(0.05, max(results_to_plot$yvals_gain), by = 0.05),
        colour = "#e6e6e6",
        size = 0.5
    )
    acc_tot_base = aes(
        y = yvals_2,
        text = paste0(
            'Effect size: ',
            ro(d_case1_vs_case2, 3),
            "\nInitial accuracy: ",
            ro(yvals_1, 3, leading_zero = FALSE),
            "\nNew accuracy: ",
            ro(yvals_2, 3, leading_zero = FALSE),
            "\nAccuracy gain: ",
            ro(yvals_gain, 3, leading_zero = FALSE)
        )
    )
    acc_total_separate =  geom_line(size = 0.7, acc_tot_base,
                                    linetype = "solid")
    acc_total_combined =  geom_line(size = 0.7, acc_tot_base,
                                    linetype = "dashed")
    acc_gain_combined = geom_line(
        size = 0.7,
        aes(
            y = yvals_gain - 0.1 + round(min(results_to_plot$yvals_1), 1),
            text = paste0(
                'Effect size: ',
                ro(d_case1_vs_case2, 3),
                "\nInitial accuracy: ",
                ro(yvals_1, 3, leading_zero = FALSE),
                "\nAccuracy gain: ",
                ro(yvals_gain, 3, leading_zero = FALSE)
            )
        ),
        linetype = "solid"
    )
    acc_gain_separate = geom_line(size = 0.7,
                                  aes(
                                      y = yvals_gain,
                                      text = paste0(
                                          'Effect size: ',
                                          ro(d_case1_vs_case2, 3),
                                          "\nInitial accuracy: ",
                                          ro(yvals_1, 3, leading_zero = FALSE),
                                          "\nNew accuracy: ",
                                          ro(yvals_2, 3, leading_zero = FALSE),
                                          "\nAccuracy gain: ",
                                          ro(yvals_gain, 3, leading_zero = FALSE)
                                      )
                                  ),
                                  linetype = "solid")
    acc_gain_scale = scale_y_continuous(
        breaks = round(seq(0.6, 1.0, by = 0.05), 2),
        sec.axis = sec_axis(
            ~ . + 0.1 - round(min(results_to_plot$yvals_1), 1),
            name = ylabel_gain,
            breaks = round(seq(
                min(results_to_plot$yvals_gain),
                max(results_to_plot$yvals_gain),
                by = 0.05
            ), 2)
        )
    )
    plot_comb = theplot + hlines_comb + acc_total_combined +
        acc_gain_combined + acc_gain_scale + ylab(ylabel_total) +
        theme(
            legend.position = "bottom",
            legend.title = element_text(face = 'italic'),
            text = element_text(family = "serif", size = 19)
        )  + xlab(xlabel_all) +
        guides(color = guide_legend(title.position = "top"))
    plot_total = theplot + hlines_tot + acc_total_separate  +
        ylab(ylabel_total) + xlab(FALSE) +
        theme(legend.position = "none",
              text = element_text(family = "serif", size = 12))
    plot_gain = theplot + hlines_gain + acc_gain_separate + xlab(FALSE) +
        ylab(ylabel_gain) + theme(legend.position = "none",
                                  text = element_text(family = "serif", size = 12))
    
    return(list(
        plot_comb,
        plotly::config(
            plotly::ggplotly(plot_total, tooltip = "text"),
            displaylogo = FALSE,
            modeBarButtonsToRemove = list('autoScale2d',
                                          'pan2d',
                                          'zoom2d',
                                          'zoomIn2d',
                                          'zoomOut2d')
        ),
        plotly::config(
            plotly::ggplotly(plot_gain, tooltip = "text"),
            displaylogo = FALSE,
            modeBarButtonsToRemove = list('autoScale2d',
                                          'pan2d',
                                          'zoom2d',
                                          'zoomIn2d',
                                          'zoomOut2d')
        )
    ))
}

ui <- fluidPage(
    theme = shinytheme("darkly"),
    tags$head(tags$style(
        HTML(
            ".form-control { height:auto; padding:3px 15px;}
            .col-sm-8 .tabbable {margin-right:10px; margin-bottom:10px;}
            .well {padding:5px 19px 19px 19px;}"
        )
    )),
    sidebarLayout(
        position = "left",
        sidebarPanel(tabsetPanel(
            tabPanel(
                "Numbers",
                splitLayout(
                    numericInput("sd_g", "Case SD", 1, min = 0),
                    numericInput("sd_i", "Control SD", 1, min = 0),
                    numericInput("N", "Sample size", 100, min = 100, max = 30000)
                ),
                p(strong(
                    'Initial effect sizes of "case 1" vs. "control":'
                )),
                splitLayout(
                    numericInput("gi1_start", "Min.", 0.5, min = 0, max = 10),
                    numericInput("gi1_end", "Max.", 2.5, min = 0, max = 10),
                    numericInput("gi1_step", "Step", 1.0, min = 0.05, max = 10, step = 0.025)
                ),
                p(strong('Effect sizes of "case 1" vs. "case 2":')),
                splitLayout(
                    numericInput("gg_start", "Min.", 0.0, min = 0, max = 10),
                    numericInput("gg_end", "Max.", 1.2, min = 0, max = 10),
                    numericInput("gg_step", "Step", 0.5, min = 0.025, max = 10, step = 0.025)
                ),
                hr(),
                selectInput(
                    "yval_opt",
                    "Diagnostic accuracy measure (rate/AUC)",
                    c(
                        "Rate of correct detection" = "acc",
                        "Area under the curve" = "auc"
                    )
                ),
                selectInput(
                    "legend_var",
                    "Legend content",
                    c(
                        "Initial effect size" = 'd_1',
                        "Initial accuracy (rate/AUC)" = 'acc1'
                    )
                ),
                hr(),
                actionButton("recalc", "UPDATE PLOTS AND TABLE", class = "btn btn-primary")
            ),
            tabPanel(
                "Texts",
                textInput(
                    "ylabel_total",
                    'Y axis label for total',
                    'Accuracy: "case 2" vs. "control"\n'
                ),
                textInput("ylabel_gain", 'Y axis label for gain', 'Accuracy gain\n'),
                textInput("xlabel_all", 'X axis label', '\nEffect size: "case 1" vs. "case 2"'),
                textInput(
                    "legend_titl",
                    'Legend title',
                    'Initial effect size: "case 1" vs. "control"'
                ),
                hr(),
                actionButton("recalc2", "UPDATE PLOTS AND TABLE", class = "btn btn-primary")
            )
        ),
        tabPanel("Info", # perhaps elsewhere, perhaps with some link button or whatever
                 hr())),
        mainPanel(tabsetPanel(
            tabPanel("Plots",
                     fluidRow(
                         column(
                             7,
                             tags$h3("Combined Plot", align = 'center'),
                             withSpinner(plotOutput("esdc_plot_comb"))
                         ),
                         column(
                             5,
                             tags$h3("Interactive Subplots", align = 'center'),
                             fluidRow(withSpinner(
                                 plotlyOutput("esdc_plot_tot", height = "300px")
                             ),
                             withSpinner(
                                 plotlyOutput("esdc_plot_gain", height =
                                                  "300px")
                             ))
                         )
                     )),
            tabPanel("Large Combined Plot",
                     withSpinner(
                         plotOutput("esdc_plot_comb2", height = "600px")
                     )),
            tabPanel(
                "Large Interactive Subplots",
                fluidRow(withSpinner(
                    plotlyOutput("esdc_plot_tot2", height = "600px")
                ),
                withSpinner(
                    plotlyOutput("esdc_plot_gain2", height = "600px")
                ))
            ),
            tabPanel("Table", withSpinner(dataTableOutput("esdc_table")))
        ))
    )
)

server <- function(input, output) {
    res_tabl <-
        eventReactive(c(input$recalc, input$recalc2),
                      ignoreNULL = FALSE, {
                          prep_sim(
                              gg_start = input$gg_start,
                              gg_end = input$gg_end,
                              gg_step = input$gg_step,
                              gi1_start = input$gi1_start,
                              gi1_end = input$gi1_end,
                              gi1_step = input$gi1_step,
                              sd_g = input$sd_g,
                              sd_i = input$sd_i,
                              N = input$N
                          )
                      })
    threeplots <-
        eventReactive(c(input$recalc, input$recalc2),
                      ignoreNULL = FALSE, {
                          prep_plot(
                              results_to_plot = res_tabl(),
                              yval_opt = input$yval_opt,
                              ylabel_total = input$ylabel_total,
                              ylabel_gain = input$ylabel_gain,
                              xlabel_all = input$xlabel_all,
                              legend_titl = input$legend_titl,
                              legend_var = input$legend_var
                          )
                      })
    
    output$esdc_plot_comb <- renderPlot({
        threeplots()[[1]]
    })
    output$esdc_plot_tot <- renderPlotly({
        threeplots()[[2]]
    })
    output$esdc_plot_gain <- renderPlotly({
        threeplots()[[3]]
    })
    output$esdc_plot_comb2 <- renderPlot({
        threeplots()[[1]]
    })
    output$esdc_plot_tot2 <- renderPlotly({
        threeplots()[[2]]
    })
    output$esdc_plot_gain2 <- renderPlotly({
        threeplots()[[3]]
    })
    output$esdc_table <- renderDataTable({
        res_tabl()
    })
}

shinyApp(ui = ui, server = server)
