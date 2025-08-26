#!/bin/bash

case "$1" in
  start)
    echo "Starting PostgreSQL database..."
    docker start textbook_assistant_db 2>/dev/null || ./setup_postgres.sh
    echo "Database is running on localhost:5432"
    ;;
  stop)
    echo "Stopping PostgreSQL database..."
    docker stop textbook_assistant_db
    echo "Database stopped"
    ;;
  restart)
    echo "Restarting PostgreSQL database..."
    docker restart textbook_assistant_db
    echo "Database restarted"
    ;;
  status)
    if docker ps | grep -q textbook_assistant_db; then
      echo "✅ PostgreSQL database is running"
      echo "Connection: localhost:5432"
      echo "Database: textbook_assistant"
      echo "Username: textbook_user"
    else
      echo "❌ PostgreSQL database is not running"
      echo "Run './manage_db.sh start' to start it"
    fi
    ;;
  logs)
    docker logs textbook_assistant_db
    ;;
  connect)
    docker exec -it textbook_assistant_db psql -U textbook_user -d textbook_assistant
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|logs|connect}"
    echo ""
    echo "Commands:"
    echo "  start   - Start the PostgreSQL database"
    echo "  stop    - Stop the PostgreSQL database"
    echo "  restart - Restart the PostgreSQL database"
    echo "  status  - Check if database is running"
    echo "  logs    - Show database logs"
    echo "  connect - Connect to database with psql"
    exit 1
    ;;
esac
