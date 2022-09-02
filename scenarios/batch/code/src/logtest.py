import azlog


log = azlog.getLogger(__name__)

azlog.setDebug(True)
log.debug(f"debug: test it out") 
log.info(f"info: test it out") 
log.warning(f"warn: test it out") 
log.error(f"error: test it out") 
log.critical(f"critical: test it out") 

