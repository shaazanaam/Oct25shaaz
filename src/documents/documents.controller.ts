import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Req,
  Query,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiSecurity,
  ApiQuery,
} from "@nestjs/swagger";
import { DocumentsService } from "./documents.service";
import { CreateDocumentDto } from "./dto/create-document.dto";
import { UpdateDocumentDto } from "./dto/update-document.dto";
import { TenantGuard } from "../guards/tenant.guard";

@ApiTags("documents")
@Controller("documents")
@UseGuards(TenantGuard)
@ApiSecurity("X-Tenant-Id")
export class DocumentsController {
  constructor(private readonly documentsService: DocumentsService) {}

  @Post()
  @ApiOperation({
    summary: "Register a new document",
    description:
      "Creates document metadata. Phase 7 Enhancement: Will handle file upload to S3/MinIO and generate embeddings.",
  })
  @ApiResponse({ status: 201, description: "Document created successfully" })
  create(@Body() createDocumentDto: CreateDocumentDto, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.documentsService.create(createDocumentDto, tenantId);
  }

  @Get()
  @ApiOperation({ summary: "List all documents for tenant" })
  @ApiResponse({ status: 200, description: "Documents retrieved successfully" })
  findAll(@Req() req: any) {
    const tenantId = req.tenant.id;
    return this.documentsService.findAll(tenantId);
  }

  @Get("search")
  @ApiOperation({
    summary: "Search documents",
    description:
      "Basic text search. Phase 7 Enhancement: Will use Qdrant vector search for semantic matching.",
  })
  @ApiQuery({ name: "q", required: true, description: "Search query" })
  @ApiResponse({ status: 200, description: "Search results retrieved" })
  search(@Query("q") query: string, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.documentsService.search(tenantId, query);
  }

  @Get(":id")
  @ApiOperation({ summary: "Get document by ID" })
  @ApiResponse({ status: 200, description: "Document retrieved successfully" })
  @ApiResponse({ status: 404, description: "Document not found" })
  findOne(@Param("id") id: string, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.documentsService.findOne(id, tenantId);
  }

  @Patch(":id")
  @ApiOperation({ summary: "Update document metadata" })
  @ApiResponse({ status: 200, description: "Document updated successfully" })
  @ApiResponse({ status: 404, description: "Document not found" })
  update(
    @Param("id") id: string,
    @Body() updateDocumentDto: UpdateDocumentDto,
    @Req() req: any
  ) {
    const tenantId = req.tenant.id;
    return this.documentsService.update(id, tenantId, updateDocumentDto);
  }

  @Delete(":id")
  @ApiOperation({
    summary: "Delete document",
    description:
      "Deletes document metadata. Phase 7 Enhancement: Will also delete file from storage and embeddings from vector DB.",
  })
  @ApiResponse({ status: 200, description: "Document deleted successfully" })
  @ApiResponse({ status: 404, description: "Document not found" })
  remove(@Param("id") id: string, @Req() req: any) {
    const tenantId = req.tenant.id;
    return this.documentsService.remove(id, tenantId);
  }
}
