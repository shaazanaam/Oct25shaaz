import { Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../services/prisma.service";
import { CreateDocumentDto } from "./dto/create-document.dto";
import { UpdateDocumentDto } from "./dto/update-document.dto";

@Injectable()
export class DocumentsService {
  constructor(private prisma: PrismaService) {}

  async create(createDocumentDto: CreateDocumentDto, tenantId: string) {
    const document = await this.prisma.document.create({
      data: {
        source: createDocumentDto.source,
        uri: createDocumentDto.uri,
        title: createDocumentDto.title,
        metadata: createDocumentDto.metadata || {},
        tenantId: tenantId,
      },
    });

    return document;
  }

  async findAll(tenantId: string) {
    const documents = await this.prisma.document.findMany({
      where: { tenantId },
      orderBy: {
        createdAt: "desc",
      },
    });

    return documents;
  }

  async findOne(id: string, tenantId: string) {
    const document = await this.prisma.document.findUnique({
      where: { id },
    });

    if (!document) {
      throw new NotFoundException("Document not found");
    }

    if (document.tenantId !== tenantId) {
      throw new NotFoundException("Document not found");
    }

    return document;
  }

  async update(
    id: string,
    tenantId: string,
    updateDocumentDto: UpdateDocumentDto
  ) {
    // Verify ownership
    await this.findOne(id, tenantId);

    try {
      const document = await this.prisma.document.update({
        where: { id },
        data: updateDocumentDto,
      });

      return document;
    } catch (error) {
      if (error.code === "P2025") {
        throw new NotFoundException("Document not found");
      }
      throw error;
    }
  }

  async remove(id: string, tenantId: string) {
    // Verify ownership
    await this.findOne(id, tenantId);

    try {
      await this.prisma.document.delete({
        where: { id },
      });

      // TODO: Phase 7 Enhancement - Delete actual file from storage (S3/MinIO)
      // TODO: Phase 7 Enhancement - Delete embeddings from vector DB (Qdrant)

      return { message: "Document deleted successfully" };
    } catch (error) {
      if (error.code === "P2025") {
        throw new NotFoundException("Document not found");
      }
      throw error;
    }
  }

  /**
   * Search documents (placeholder for Phase 7 enhancement with vector search)
   */
  async search(tenantId: string, query: string) {
    // TODO: Phase 7 Enhancement - Implement semantic search via Qdrant
    // For now, just do basic text search on title

    const documents = await this.prisma.document.findMany({
      where: {
        tenantId,
        OR: [
          { title: { contains: query, mode: "insensitive" } },
          { uri: { contains: query, mode: "insensitive" } },
        ],
      },
      orderBy: {
        updatedAt: "desc",
      },
    });

    return {
      query,
      results: documents,
      note: "Phase 7 Enhancement: Will use vector search (Qdrant) for semantic matching",
    };
  }
}
