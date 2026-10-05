library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(DT)
library(scales)

data <- read.csv("data/tourism_data.csv", stringsAsFactors = FALSE)
data$Date <- as.Date(data$Date)
data$Month <- floor_date(data$Date, "month")

ui <- fluidPage(
  tags$head(
    tags$title("WanderScope | Tourism Analytics"),
    tags$link(rel="preconnect", href="https://fonts.googleapis.com"),
    tags$link(rel="preconnect", href="https://fonts.gstatic.com", crossorigin=""),
    tags$link(href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap", rel="stylesheet"),
    tags$link(rel="stylesheet", href="styles.css")
  ),
  div(class="app-shell",
    div(class="topbar",
      div(class="brand",
        span(class="brand-mark","✦"),
        div(span("WANDER",class="brand-main"),span("SCOPE",class="brand-sub"))
      ),
      div(class="topnav",
        tags$a(href="#overview", class="nav-link active", `data-section`="overview", "Overview"),
        tags$a(href="#destinations", class="nav-link", `data-section`="destinations", "Destinations"),
        tags$a(href="#insights", class="nav-link", `data-section`="insights", "Insights"),
        tags$a(href="#bookings", class="nav-link", `data-section`="bookings", "Bookings")
      ),
      div(class="live-pill", span(class="pulse"), "Live dataset")
    ),

    div(id="hero", class="hero",
      div(class="hero-copy",
        div(class="eyebrow","TOURISM INTELLIGENCE • 2025–2026"),
        h1("See where the journey",br(),span("takes your business.",class="hero-accent")),
        p("A visual command center for destinations, visitors, stays and travel performance."),
        div(class="hero-actions",
          actionButton("explore_btn","Explore destinations  →",class="primary-btn"),
          downloadButton("download","Export data",class="ghost-btn")
        )
      ),
      div(class="hero-orbit", div(class="orbit-ring"), div(class="orbit-core","✈"), div(class="orbit-label","TRAVEL"))
    ),

    div(class="filterbar",
      div(class="filter-title","FILTER JOURNEY"),
      div(class="filter-item", dateRangeInput("date","Date range",start=min(data$Date),end=max(data$Date),format="dd M yyyy",separator=" → ")),
      div(class="filter-item", selectInput("destination","Destination",c("All",sort(unique(data$Destination))),"All")),
      div(class="filter-item", selectInput("type","Experience",c("All",sort(unique(data$Destination_Type))),"All")),
      div(class="filter-item", selectInput("origin","Visitor origin",c("All",sort(unique(data$Visitor_Origin))),"All"))
    ),

    div(class="content",
      tabsetPanel(
        id="main_section",
        type="hidden",
        tabPanel("overview",
          div(id="overview", class="section-head", div(h2("Journey at a glance"),p("Key signals from your filtered tourism activity.")),
              div(class="date-chip", textOutput("range_text"))),
          div(class="kpi-grid",
            div(class="kpi-card kpi-1",div(class="kpi-icon","✦"),div(class="kpi-label","BOOKINGS"),div(class="kpi-value",textOutput("kpi_bookings")),div(class="kpi-note","total journeys")),
            div(class="kpi-card kpi-2",div(class="kpi-icon","₹"),div(class="kpi-label","REVENUE"),div(class="kpi-value",textOutput("kpi_revenue")),div(class="kpi-note","travel value")),
            div(class="kpi-card kpi-3",div(class="kpi-icon","◌"),div(class="kpi-label","TRAVELERS"),div(class="kpi-value",textOutput("kpi_travelers")),div(class="kpi-note","people on tour")),
            div(class="kpi-card kpi-4",div(class="kpi-icon","★"),div(class="kpi-label","AVG. RATING"),div(class="kpi-value",textOutput("kpi_rating")),div(class="kpi-note","visitor sentiment"))
          ),
          div(class="feature-grid",
            div(class="panel wide",div(class="panel-head",h3("Travel demand over time"),span("MONTHLY TREND")),plotOutput("trend",height="300px")),
            div(class="panel",div(class="panel-head",h3("Where visitors come from"),span("ORIGIN")),plotOutput("origin_plot",height="300px"))
          )
        ),

        tabPanel("destinations",
          div(id="destinations", class="section-head", div(h2("Destination studio"),p("Discover where demand, value and visitor satisfaction are strongest."))),
          div(class="feature-grid",
            div(class="panel",div(class="panel-head",h3("Top destinations"),span("RANKING")),uiOutput("dest_cards")),
            div(class="panel",div(class="panel-head",h3("Experience mix"),span("TYPE")),plotOutput("type_plot",height="280px"))
          ),
          div(class="panel",div(class="panel-head",h3("Destination performance"),span("REVENUE")),plotOutput("dest_plot",height="340px"))
        ),

        tabPanel("insights",
          div(id="insights", class="section-head", div(h2("Travel insights"),p("Understand the shape of your tourism audience and trip behavior."))),
          div(class="feature-grid",
            div(class="panel",div(class="panel-head",h3("Visitor origin"),span("TOP MARKETS")),plotOutput("origin_insight",height="330px")),
            div(class="panel",div(class="panel-head",h3("Trip profile"),span("NIGHTS")),plotOutput("nights_plot",height="330px"))
          ),
          div(class="insight-strip",
            div(class="insight-box",strong("Best destination"),span(textOutput("best_dest"))),
            div(class="insight-box",strong("Top visitor market"),span(textOutput("best_origin"))),
            div(class="insight-box",strong("Average stay"),span(textOutput("avg_nights")))
          )
        ),

        tabPanel("bookings",
          div(id="bookings", class="section-head", div(h2("Booking explorer"),p("Search, sort and export the underlying travel activity."))),
          div(class="table-panel",DTOutput("table"))
        )
      )
    ),
    div(class="footer",span("WANDERSCOPE"),span("Tourism analytics • Built with R & Shiny"))
  ),
  tags$script(HTML("
    $(function(){
      function activate(section){
        $('.nav-link').removeClass('active');
        $('.nav-link[data-section=\"'+section+'\"]').addClass('active');
        var target = section === 'overview' ? 'overview' : section;
        $('#main_section li').each(function(){
          var txt = $(this).text().trim().toLowerCase();
          if(txt === section){
            $(this).find('a').trigger('click');
          }
        });
        window.scrollTo({top:0, behavior:'smooth'});
      }
      $('.nav-link').on('click', function(e){
        e.preventDefault();
        activate($(this).data('section'));
      });
      $('#explore_btn').on('click', function(){ activate('destinations'); });
    });
  "))
)

server <- function(input, output, session) {
  filtered <- reactive({
    x <- data
    if(!is.null(input$date)) x <- x[x$Date >= input$date[1] & x$Date <= input$date[2],]
    if(input$destination != "All") x <- x[x$Destination == input$destination,]
    if(input$type != "All") x <- x[x$Destination_Type == input$type,]
    if(input$origin != "All") x <- x[x$Visitor_Origin == input$origin,]
    x
  })

  output$range_text <- renderText(paste(format(input$date[1],"%d %b %Y"),"—",format(input$date[2],"%d %b %Y")))
  output$kpi_bookings <- renderText(scales::comma(nrow(filtered())))
  output$kpi_revenue <- renderText(scales::dollar(sum(filtered()$Revenue), prefix="₹", big.mark=",", accuracy=1))
  output$kpi_travelers <- renderText(scales::comma(sum(filtered()$Travelers)))
  output$kpi_rating <- renderText(sprintf("%.1f / 5", mean(filtered()$Rating)))

  output$trend <- renderPlot({
    x <- filtered() %>% group_by(Month) %>% summarise(Revenue=sum(Revenue),Bookings=n(),.groups="drop")
    ggplot(x,aes(Month,Revenue))+geom_area(alpha=.18)+geom_line(linewidth=1.2)+geom_point(size=2.2)+
      scale_y_continuous(labels=dollar_format(prefix="₹",suffix=""))+labs(x=NULL,y=NULL)+theme_minimal(base_family="DM Sans")+
      theme(panel.grid.minor=element_blank(),panel.grid.major.x=element_blank())
  })
  origin_data <- reactive({ filtered() %>% count(Visitor_Origin,sort=TRUE) %>% slice_head(n=8) })
  output$origin_plot <- renderPlot({
    x <- origin_data()
    ggplot(x,aes(reorder(Visitor_Origin,n),n))+geom_col(width=.62)+coord_flip()+
      labs(x=NULL,y=NULL)+theme_minimal(base_family="DM Sans")+theme(panel.grid.minor=element_blank(),panel.grid.major.y=element_blank())
  })
  output$origin_insight <- renderPlot({
    x <- origin_data()
    ggplot(x,aes(reorder(Visitor_Origin,n),n))+geom_col(width=.62)+coord_flip()+
      labs(x=NULL,y="Bookings")+theme_minimal(base_family="DM Sans")+theme(panel.grid.minor=element_blank(),panel.grid.major.y=element_blank())
  })
  output$type_plot <- renderPlot({
    x <- filtered() %>% count(Destination_Type)
    ggplot(x,aes("",n,fill=Destination_Type))+geom_col(width=1,color="white")+coord_polar("y")+theme_void()+theme(legend.position="bottom",text=element_text(family="DM Sans"))
  })
  output$dest_plot <- renderPlot({
    x <- filtered() %>% group_by(Destination) %>% summarise(Revenue=sum(Revenue),Bookings=n(),.groups="drop") %>% arrange(Revenue) %>% slice_tail(n=8)
    ggplot(x,aes(reorder(Destination,Revenue),Revenue))+geom_col(width=.62)+coord_flip()+
      scale_y_continuous(labels=dollar_format(prefix="₹",suffix=""))+labs(x=NULL,y=NULL)+theme_minimal(base_family="DM Sans")+
      theme(panel.grid.minor=element_blank(),panel.grid.major.y=element_blank())
  })
  output$nights_plot <- renderPlot({
    x <- filtered() %>% count(Nights)
    ggplot(x,aes(Nights,n))+geom_col(width=.65)+geom_line(aes(group=1),linewidth=1)+geom_point(size=2)+
      labs(x="Nights",y="Bookings")+theme_minimal(base_family="DM Sans")+theme(panel.grid.minor=element_blank())
  })
  output$dest_cards <- renderUI({
    x <- filtered() %>% group_by(Destination,Destination_Type) %>% summarise(Revenue=sum(Revenue),Rating=mean(Rating),Bookings=n(),.groups="drop") %>% arrange(desc(Revenue)) %>% slice_head(n=5)
    tagList(lapply(seq_len(nrow(x)), function(i) {
      div(class="destination-card",div(class="rank",sprintf("%02d",i)),
          div(class="dest-info",strong(x$Destination[i]),span(paste(x$Destination_Type[i], "•", x$Bookings[i],"bookings"))),
          div(class="dest-score",span(sprintf("%.1f",x$Rating[i]),class="score"),span("★",class="star")))
    }))
  })
  output$best_dest <- renderText({
    x <- filtered() %>% group_by(Destination) %>% summarise(Revenue=sum(Revenue),.groups="drop") %>% arrange(desc(Revenue))
    if(nrow(x)) x$Destination[1] else "—"
  })
  output$best_origin <- renderText({
    x <- filtered() %>% count(Visitor_Origin,sort=TRUE)
    if(nrow(x)) x$Visitor_Origin[1] else "—"
  })
  output$avg_nights <- renderText(sprintf("%.1f nights", mean(filtered()$Nights)))
  output$table <- renderDT({
    filtered() %>% select(Booking_ID,Date,Destination,Visitor_Origin,Travelers,Nights,Accommodation,Transport,Package,Revenue,Rating,Status) %>%
      mutate(Revenue=round(Revenue,0)) %>%
      datatable(rownames=FALSE, options=list(pageLength=10,scrollX=TRUE,dom="<'dt-top'f>rt<'dt-bottom'ip>"))
  })
  output$download <- downloadHandler(
    filename=function() paste0("tourism_filtered_",Sys.Date(),".csv"),
    content=function(file) write.csv(filtered(),file,row.names=FALSE)
  )
}
shinyApp(ui,server)
